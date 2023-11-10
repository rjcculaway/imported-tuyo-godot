extends HBoxContainer

@export var HeartIcon: PackedScene

func _on_play_lives_changed(lives: int):
	var children: Array[Node] = get_children()

	var difference: int = children.size() - lives

	print_debug(difference)

	# Make up for the difference either by adding hearts or removing them.
	if difference < 0:
		for i in range(abs(difference)):
			add_child(HeartIcon.instantiate())

	if difference > 0:
		for i in range(min(children.size(), abs(difference))):
			children[i].queue_free()
