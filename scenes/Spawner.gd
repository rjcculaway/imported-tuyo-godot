extends Node2D

@export var spawning_patterns: Array[Resource]
@export var spawning_line: Line2D
@export var word_bank: Resource

# # Called when the node enters the scene tree for the first time.
func _ready():
	spawn_fishes()


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func spawn_fishes() -> void:
	var spawning_pattern: Resource = spawning_patterns[0]
	var num_of_fishes: int = spawning_pattern.fish_types.size()
	for i in range(num_of_fishes):
		var new_fish: Node2D = spawning_pattern.fish_types[i].instantiate()
		new_fish.position.y = lerp(spawning_line.points[0].y, spawning_line.points[1].y, 1.0 / (num_of_fishes + 1) * (i + 1.0))
		new_fish.get_word(word_bank)
		new_fish.add_to_group("fishes", true)
		add_child(new_fish)
	return

func _on_spawn_timer_timeout():
	spawn_fishes()
	return
