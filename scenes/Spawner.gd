extends Node2D

@export var spawning_patterns: Array[Resource]
@export var mermaid_scene: PackedScene
@export var spawning_line: Line2D
@export var word_bank: Resource

enum SpawnerState {
	SPAWNER_NORMAL,
	SPAWNER_MERMAID
}

var current_state: SpawnerState = SpawnerState.SPAWNER_NORMAL

# # Called when the node enters the scene tree for the first time.
func _ready():
	spawn_fishes()

func spawn_fishes() -> void:
	var parent: Play = get_parent()
	var depth: int = parent.depth

	var range_of_spawning_patterns: int = clamp(sqrt(depth) / 4, 1, spawning_patterns.size() - 1) 

	var spawning_pattern: Resource = spawning_patterns[randi() % (range_of_spawning_patterns)]
	var num_of_fishes: int = spawning_pattern.fish_types.size()
	for i in range(num_of_fishes):
		var new_fish: Node2D = spawning_pattern.fish_types[i].instantiate()
		var fish_component: Fish = new_fish.get_node("Fish")
		new_fish.position.y = lerp(spawning_line.points[0].y, spawning_line.points[1].y, 1.0 / (num_of_fishes + 1) * (i + 1.0)) # Evenly divide the spawning points along the vertical axis.
		new_fish.get_word(word_bank)
		new_fish.add_to_group("fishes", true)
		parent.connect("current_typed_word_changed", fish_component._on_current_word_changed)
		fish_component.connect("fish_caught", parent._on_fish_caught)
		$ActiveFishes.add_child(new_fish)
	return

func spawn_mermaid() -> void:
	# var parent: Play = get_parent()
	var mermaid: Mermaid = mermaid_scene.instantiate()
	mermaid.position = (get_node('%MermaidSpawnPoint') as Marker2D).position
	$ActiveFishes.add_child(mermaid)

func _on_spawn_timer_timeout():
	match current_state:
		SpawnerState.SPAWNER_NORMAL:
			spawn_fishes()
	return

