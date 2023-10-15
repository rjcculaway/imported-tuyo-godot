extends Node2D

@export var fish_types: Array[PackedScene]
@export var spawning_line: Line2D
@export var word_bank: Resource

# # Called when the node enters the scene tree for the first time.
func _ready():
	spawn_fishes()


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func spawn_fishes() -> void:
	for i in range(3):
		var new_fish: Node2D = fish_types[0].instantiate()
		new_fish.position.y = lerp(spawning_line.points[0].y, spawning_line.points[1].y, randf())
		add_child(new_fish)
	return

func _on_spawn_timer_timeout():
	return
