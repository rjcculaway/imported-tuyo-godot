@tool
extends PointLight2D

@export var min_underwater_light_reach: float = 0.75
@export var max_underwater_light_reach: float = 0.35

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	# var current_fill: Vector2 = get_texture().get_fill_to()
	# var current_time: float = Time.get_unix_time_from_system()
	# var new_y: float = remap(sin(current_time), -1.0, 1.0, min_underwater_light_reach, max_underwater_light_reach)
	# var new_fill: Vector2 = Vector2(current_fill.x, new_y)
	# (get_texture() as GradientTexture2D).set_fill_to(new_fill)
