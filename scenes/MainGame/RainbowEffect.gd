extends ColorRect

func set_rainbow_opacity(current_progress: float):
	material.set_shader_parameter(&"rainbow_opacity", current_progress)

func _on_play_entered_state(new_state: Play.GameStates):
	
	match (new_state):
		Play.GameStates.GAME_MERMAID:
			var tween = create_tween()
			tween.tween_method(set_rainbow_opacity, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_SINE)
		_:
			var tween = create_tween()
			tween.tween_method(set_rainbow_opacity, material.get_shader_parameter(&"rainbow_opacity"), 0.0, 0.5).set_trans(Tween.TRANS_SINE)
			pass

	return
