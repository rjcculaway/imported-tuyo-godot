extends Node2D
class_name Play

signal current_typed_word_changed(current_word: String)
signal lives_changed(lives: int)
signal depth_changed(depth: int)
signal score_changed(score: int)
signal fish_net_power_changed(fish_net_power: int)
signal activated_fish_net()
signal entered_state(new_state: GameStates)

@export var max_lives: int = 3
@export var max_fish_net_power: int = 100
@export var mermaid_appearance_depth: int = 2 # Which depth does the mermaid appear
@export var erase_cost: int = 5 # The fish net cost when performing an erase. 
@export var initial_depth_timer_wait_time: float = 15.0

enum GameStates {
	TRANSITIONING,
	GAME_PAUSED,
	GAME_NORMAL,
	GAME_MERMAID,
	GAME_OVER
}

var current_state: GameStates = GameStates.TRANSITIONING

var lives: int = 0 :
	set(new_lives):
		var clamped_new_lives = max(new_lives, 0)
		lives_changed.emit(clamped_new_lives)
		lives = clamped_new_lives
var score: int = 0 :
	set(new_score):
		score_changed.emit(new_score)
		score = new_score
var depth: int = 0 :
	set(new_depth):
		depth_changed.emit(new_depth)
		depth = new_depth
var fish_net_power: int = 0 :
	set(new_fish_net_power):
		fish_net_power_changed.emit(new_fish_net_power)
		fish_net_power = min(new_fish_net_power, max_fish_net_power)

var current_typed_word: String = "" :
	set(updated_word):
		current_typed_word = updated_word.to_lower()
		current_typed_word_changed.emit(current_typed_word)

var number_of_times_mermaid_appeared: int = 0;

func enter_state(next_state: GameStates) -> void:
	exit_state(current_state)
	current_state = GameStates.TRANSITIONING
	print_debug("Transitioning to state: " + GameStates.keys()[next_state])
	match next_state:
		GameStates.GAME_NORMAL:
			%DepthIncreaseTimer.start()
			current_typed_word = ""
		GameStates.GAME_MERMAID:
			current_typed_word = ""
		GameStates.GAME_OVER:
			save_high_scores()
			var high_scores = load_high_scores()

			%HighScoresList.clear()
			for high_score in high_scores:
				%HighScoresList.add_item(str(high_score["player_name"]), null, false)
				%HighScoresList.add_item(str(high_score["player_score"]), null, false)
			%Spawner.enter_state(Spawner.SpawnerState.SPAWNER_GAME_OVER)
				
			%HighScoresList.set_same_column_width(false)
			%HighScoresList.set_same_column_width(true)
			%GameOverPanel.visible = true
		_:
			pass
	current_state = next_state
	entered_state.emit(current_state)
	print_debug("Entered state: " + GameStates.keys()[current_state])
	return

func exit_state(exiting_state: GameStates) -> void:
	print_debug("Exiting state: " + GameStates.keys()[exiting_state])
	match exiting_state:
		GameStates.GAME_NORMAL:
			%DepthIncreaseTimer.stop()
		GameStates.GAME_OVER:
			# Reset values
			score = 0
			fish_net_power = 0
			lives = 3
			depth = 0
			%Spawner.enter_state(Spawner.SpawnerState.SPAWNER_NORMAL)
			$DepthIncreaseTimer.wait_time = initial_depth_timer_wait_time
			%GameOverPanel.visible = false
		_:
			pass
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	lives = max_lives
	enter_state(GameStates.GAME_NORMAL)
	fish_net_power = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	match current_state:
		GameStates.GAME_OVER:
			pass
		GameStates.TRANSITIONING:
			pass
		_:
			if event is InputEventKey:
				event = event as InputEventKey
				
				if event.is_action_pressed("type_letter"): # Not sure if this is a good way to capture the input... and we're concatenating strings here by the way!
					current_typed_word += event.as_text_keycode()

				if event.is_action_pressed("reset_word"):
					if current_typed_word.length() > 0:
						current_typed_word = ""
						fish_net_power = max(0, fish_net_power - erase_cost)	# Erasing the currently typed word has a cost

				if event.is_action_pressed("activate_fish_net"):
					if fish_net_power >= max_fish_net_power:
						fish_net_power = 0;
						activated_fish_net.emit()

				get_viewport().set_input_as_handled()

func _on_fish_caught(node: Node2D, fish_size: Fish.FishSize, base_point_value: int) -> void:
	match current_state:
		GameStates.GAME_OVER:
			pass
		_:
			current_typed_word = ""
			
			var tween = node.create_tween()
			tween.tween_property(node.get_node("%Fish"), "global_position", %Character.global_position, 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.parallel().tween_property(node.get_node("%Fish"), "scale", Vector2(0.0, 0.0), 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(node.queue_free)
			
			await tween.finished

			score += base_point_value * roundi(float(fish_net_power) / float(max_fish_net_power) + 1.0)
			#warning-ignore:integer_division
			fish_net_power += (1 + roundi(float(base_point_value) / 2))

			print_debug("Fish (%s) was caught for %d point(s)." % [Fish.FishSize.keys()[fish_size], base_point_value])
			
			return

func _on_bubble_popped(success: bool, bubble_score: int) -> void:
	match current_state:
		GameStates.GAME_OVER:
			pass
		_:
			if success:
				current_typed_word = ""
				score +=  bubble_score * (depth + 1)
				fish_net_power += bubble_score
	return

func _on_depth_increase_timer_timeout() -> void:
	match current_state:
		GameStates.GAME_OVER:
			pass
		GameStates.GAME_NORMAL:
			depth += 1
			$DepthIncreaseTimer.wait_time = max($DepthIncreaseTimer.wait_time - 0.5, 0.5)
		_:
			pass
	return

func _on_fish_escaped() -> void:
	match current_state:
		GameStates.GAME_NORMAL:
			print_debug("Typeable escaped!")
			lives -= 1
		_:
			pass

func _on_lives_changed(new_lives: int) -> void:
	match current_state:
		_:
			var all_lives_lost = new_lives <= 0
			if all_lives_lost:
				enter_state(GameStates.GAME_OVER)

func _on_depth_changed(new_depth) -> void:
	match current_state:
		GameStates.GAME_NORMAL:
			var should_mermaid_spawn: bool = new_depth % min(512, int(mermaid_appearance_depth * pow(number_of_times_mermaid_appeared + 1, 2))) == 0
			if should_mermaid_spawn:
				enter_state(GameStates.GAME_MERMAID)
				number_of_times_mermaid_appeared += 1
		_:
			pass


func load_high_scores() -> Array[Dictionary]:
	var save_game = FileAccess.open("user://high_scores.dat", FileAccess.READ)

	if FileAccess.get_open_error() != OK:
		return [] as Array[Dictionary]

	var high_scores: Array[Dictionary] = []


	while save_game.get_position() < save_game.get_length():
		var player_name: String = save_game.get_pascal_string()
		var player_score: int = save_game.get_64()

		high_scores.append({
			"player_name": player_name,
			"player_score": player_score
		})
	
	print_debug(high_scores)
	
	return high_scores

func save_high_scores() -> void:
	var high_scores = load_high_scores()

	high_scores.append({
		"player_name": "Player",
		"player_score": score
	})

	var high_score_comparator: Callable = func (a: Dictionary, b: Dictionary):
		return a["player_score"] > b["player_score"]
	
	high_scores.sort_custom(high_score_comparator)
	if high_scores.size() > 10:
		high_scores.resize(high_scores.size() - 1)	# Removes the last high score

	if FileAccess.file_exists("user://high_scores.dat"):
		var save_game_rename = DirAccess.rename_absolute("user://high_scores.dat", "user://high_scores.dat.bak")

		if save_game_rename != OK:
			print_debug("Creating backup file for saves failed. Stopping save.")
			return
	
	var save_file = FileAccess.open("user://high_scores.dat", FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		print_debug("Save file creation failed. Stopping save.")
		DirAccess.rename_absolute("user://high_scores.dat.bak", "user://high_scores.dat")
		return

	for i in range(len(high_scores)):
		save_file.store_pascal_string(high_scores[i]["player_name"])
		save_file.store_64((high_scores[i]["player_score"]))


func return_to_title_screen():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
