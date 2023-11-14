class_name Spawner extends Node2D

signal no_more_fishes

@export var spawning_patterns: Array[Resource]
@export var mermaid_scene: PackedScene
@export var word_bank: Resource

enum SpawnerState {
	TRANSITIONING,
	SPAWNER_NORMAL,
	SPAWNER_MERMAID
}

var current_state: SpawnerState = SpawnerState.SPAWNER_NORMAL
@onready var size_spawning_patterns: int = spawning_patterns.size() - 1

# # Called when the node enters the scene tree for the first time.
func _ready():
	enter_state(SpawnerState.SPAWNER_NORMAL)

func spawn_fishes() -> void:
	var parent: Play = get_parent()
	var depth: int = parent.depth
	var log_depth: int = int(log(depth) / log(2))
	
	var range_of_spawning_patterns: int = clamp(log_depth, 1, size_spawning_patterns) 
	print_debug("range of spawning patterns: " + str(range_of_spawning_patterns))

	var spawning_pattern: Resource = spawning_patterns[randi() % (range_of_spawning_patterns)]
	var num_of_fishes: int = spawning_pattern.fish_types.size()
	for i in range(num_of_fishes):
		var new_fish: Node2D = spawning_pattern.fish_types[i].instantiate()
		var fish_component: Fish = new_fish.get_node("Fish")
		var typeable_component: Typeable = new_fish.get_node("%Typeable")

		new_fish.position.y = lerp(%SpawningLine.points[0].y, %SpawningLine.points[1].y, 1.0 / (num_of_fishes + 1) * (i + 1.0)) # Evenly divide the spawning points along the vertical axis.
		new_fish.get_word(word_bank)
		new_fish.add_to_group("fishes", true)

		parent.connect("current_typed_word_changed", typeable_component._on_current_word_changed)
		fish_component.connect("fish_caught", parent._on_fish_caught)

		$ActiveFishes.add_child.call_deferred(new_fish)
	return

func spawn_mermaid() -> void:
	var parent: Play = get_parent()
	var mermaid: Mermaid = mermaid_scene.instantiate()
	mermaid.position = (get_node('%MermaidSpawnPoint') as Marker2D).position
	mermaid.connect(&"mermaid_over", parent.enter_state.bind(Play.GameStates.GAME_NORMAL))
	$ActiveFishes.add_child.call_deferred(mermaid)

func _on_spawn_timer_timeout():
	match current_state:
		SpawnerState.SPAWNER_NORMAL:
			spawn_fishes()
	return

func enter_state(next_state: SpawnerState) -> void:
	exit_state(current_state)
	current_state = SpawnerState.TRANSITIONING
	print_debug("Transitioning to state: " + SpawnerState.keys()[next_state])
	match next_state:
		SpawnerState.SPAWNER_NORMAL:
			%SpawnTimer.start()
			spawn_fishes()
		SpawnerState.SPAWNER_MERMAID:
			print_debug("Waiting for fishes to be gone...")

			var num_of_active_fishes: int = %ActiveFishes.get_child_count()
			var no_active_fishes: bool = num_of_active_fishes <= 0
			if not no_active_fishes:
				await no_more_fishes

			print_debug("Done waiting! Spawning mermaid!")
			spawn_mermaid()
		_:
			pass
	current_state = next_state
	print_debug("Entered state: " + SpawnerState.keys()[current_state])
	return

func exit_state(exiting_state: SpawnerState) -> void:
	print_debug("Exiting spawner state: " + SpawnerState.keys()[exiting_state])
	match exiting_state:
		SpawnerState.SPAWNER_NORMAL:
			%SpawnTimer.stop()
		_:
			pass
	return

func _on_active_fishes_reduced(node: Node) -> void:
	if not (node is Mermaid):
		var is_last_fish_captured_or_escaped: bool = %ActiveFishes.get_child_count() - 1 <= 0 # Subtract by 1 since `child_exiting_tree` emits BEFORE the node exits the tree.
		print_debug("Number of active fishes: " + str(%ActiveFishes.get_child_count() - 1))
		if is_last_fish_captured_or_escaped: 
			print_debug("No more fishes!")
			no_more_fishes.emit()
		return
