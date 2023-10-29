extends Node2D

var current_typed_word: String = "" :
	set(updated_word):
		current_typed_word = updated_word
		# print_debug(current_typed_word)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event is InputEventKey and event.is_action_pressed("type_letter"):
		event = event as InputEventKey
		
		if event.is_action_pressed("type_letter"): # Not sure if this is a good way to capture the input... and we're concatenating strings here by the way!
			current_typed_word += event.as_text_keycode()

		if event.is_action_pressed("reset_word"):
			pass
		
		get_viewport().set_input_as_handled()

	
