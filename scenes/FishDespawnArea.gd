extends Area2D

func _on_body_exited (body: Node2D):
	if body.get_parent() != null and body.get_parent().is_in_group("fishes"):
		body.get_parent().queue_free()
