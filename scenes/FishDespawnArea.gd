extends Area2D

signal fish_escaped()

func _on_body_exited (body: Node2D):
	if body.get_parent() != null and body.get_parent().is_in_group("fishes"):
		if body.current_state != Fish.FishState.FISH_INACTIVE:
			body.get_parent().queue_free()
			fish_escaped.emit()
