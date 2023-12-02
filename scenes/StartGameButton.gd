extends Button

func _on_pressed():
	%ShaneAnimationPlayer.play(&"jump")

func start_game():
	get_tree().change_scene_to_file("res://scenes/MainGame/Play.tscn")
