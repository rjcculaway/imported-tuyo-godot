@tool

extends Line2D

@export var spawning_pattern_preview: Resource :
	set(value):
		refresh_spawning_pattern_preview(value)
		spawning_pattern_preview = value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func refresh_spawning_pattern_preview(spawning_pattern: Resource) -> void:
	if Engine.is_editor_hint():
		if spawning_pattern:
			for child in get_children():
				child.queue_free()

			var num_of_fishes: int = spawning_pattern.fish_types.size()
			for i in range(num_of_fishes):
				# Evenly divide the spawning points along the vertical axis.
				var new_fish: Node2D = spawning_pattern.fish_types[i].instantiate()
				new_fish.position.y = lerp(points[0].y, points[1].y, 1.0 / (num_of_fishes + 1) * (i + 1.0)) 
				new_fish.modulate = Color.from_ok_hsl(1.0, 1.0, 1.0, 0.5)
				add_child(new_fish)