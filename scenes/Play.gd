extends Node2D
class_name Play

signal current_typed_word_changed(current_word: String)
signal lives_changed(lives: int)
signal depth_changed(depth: int)
signal score_changed(score: int)
signal fish_net_power_changed(fish_net_power: int)
signal game_over()

@export var max_lives = 3
@export var max_fish_net_power = 100

enum GameStates {
	GAME_START,
	GAME_PAUSED,
	GAME_RUNNING,
	GAME_MERMAID,
	GAME_OVER
}

var current_state: GameStates = GameStates.GAME_RUNNING

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
	match next_state:
		_:
			pass
	current_state = next_state
	return

func exit_state(exiting_state: GameStates) -> void:
	match exiting_state:
		_:
			pass
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	lives = max_lives


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	match current_state:
		GameStates.GAME_OVER:
			return
		_:
			if event is InputEventKey:
				event = event as InputEventKey
				
				if event.is_action_pressed("type_letter"): # Not sure if this is a good way to capture the input... and we're concatenating strings here by the way!
					current_typed_word += event.as_text_keycode()

				if event.is_action_pressed("reset_word"):
					current_typed_word = ""
				
				get_viewport().set_input_as_handled()


func _on_fish_caught(fish_size: Fish.FishSize, base_point_value: int) -> void:
	match current_state:
		GameStates.GAME_OVER:
			pass
		_:
			current_typed_word = ""
			score += base_point_value
			#warning-ignore:integer_division
			fish_net_power += 1 + base_point_value / 2
			print_debug("Fish (%s) was caught for %d point(s)." % [str(fish_size), base_point_value])
			return

func _on_depth_increase_timer_timeout() -> void:
	match current_state:
		GameStates.GAME_OVER:
			return
		_:
			depth += 1
			$DepthIncreaseTimer.wait_time = max($DepthIncreaseTimer.wait_time - 0.5, 0.5)

func _on_fish_escaped() -> void:
	match current_state:
		_:
			print_debug("Fish escaped!")
			lives -= 1

func _on_lives_changed(new_lives: int) -> void:
	match current_state:
		_:
			var all_lives_lost = new_lives <= 0
			if all_lives_lost:
				game_over.emit()

func _on_depth_changed(new_depth) -> void:
	match current_state:
		_:
			var should_mermaid_spawn: bool = new_depth % (500 * (number_of_times_mermaid_appeared + 1)) == 0
			if should_mermaid_spawn:
				enter_state(GameStates.GAME_MERMAID)

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

func on_mermaid_over() -> void:
	match current_state:
		GameStates.GAME_MERMAID:
			enter_state(GameStates.GAME_RUNNING)
		_:
			pass
	return

func _on_game_over() -> void:
	match current_state:
		GameStates.GAME_RUNNING:
			save_high_scores()
			enter_state(GameStates.GAME_OVER)
			get_tree().paused = true
