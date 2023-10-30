extends Node2D
class_name Play

signal current_typed_word_changed(current_word: String)
signal depth_changed(depth: int)
signal score_changed(score: int)

var score: int = 0 :
	set(new_score):
		score_changed.emit(new_score)
		score = new_score
var depth: int = 0 :
	set(new_depth):
		depth_changed.emit(new_depth)
		depth = new_depth

var current_typed_word: String = "" :
	set(updated_word):
		current_typed_word = updated_word.to_lower()
		current_typed_word_changed.emit(current_typed_word)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		
		if event.is_action_pressed("type_letter"): # Not sure if this is a good way to capture the input... and we're concatenating strings here by the way!
			current_typed_word += event.as_text_keycode()

		if event.is_action_pressed("reset_word"):
			current_typed_word = ""
		
		get_viewport().set_input_as_handled()

func _on_fish_caught(fish_size: Fish.FishSize, base_point_value: int):
	current_typed_word = ""
	score += base_point_value
	print_debug("Fish (%s) was caught for %d point(s)." % [str(fish_size), base_point_value])
	return

func _on_depth_increase_timer_timeout():
	depth += 1
	$DepthIncreaseTimer.wait_time = max($DepthIncreaseTimer.wait_time - 0.5, 0.5)