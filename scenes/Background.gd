extends Sprite2D

func _on_depth_changed(new_depth: int):
	print_debug("depth changed" + str(tanh(float(new_depth) / 1000)))
	material.set_shader_parameter(&"water_depth", tanh(float(new_depth) / 1000))