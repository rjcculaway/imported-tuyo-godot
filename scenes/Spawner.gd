class_name Spawner extends Node2D

signal no_more_fishes

@export var spawning_patterns: Array[Resource]
@export var bubble_scene: PackedScene
@export var mermaid_scene: PackedScene
@export var word_bank: Resource

const FISHES_GROUP: StringName = "fishes"

enum SpawnerState {
	TRANSITIONING,
	SPAWNER_NORMAL,
	SPAWNER_MERMAID
}

var current_state: SpawnerState = SpawnerState.TRANSITIONING
@onready var size_spawning_patterns: int = spawning_patterns.size() - 1

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
	mermaid.connect(&"spawn_bubble", spawn_bubble)
	$ActiveFishes.add_child.call_deferred(mermaid)

func spawn_bubble(spawn_position: Vector2) -> void:
	var parent: Play = get_parent()
	var bubble: Bubble = bubble_scene.instantiate()
	var typeable_component: Typeable = bubble.get_node("%Typeable")
	
	bubble.get_word(word_bank)
	bubble.position = spawn_position
	
	parent.connect("current_typed_word_changed", typeable_component._on_current_word_changed)
	bubble.connect(&"bubble_popped", parent._on_bubble_popped)

	$ActiveFishes.add_child.call_deferred(bubble)
	return

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
			for fish in get_tree().get_nodes_in_group(FISHES_GROUP):
				var fish_component: Fish = fish.get_node_or_null("Fish")
				if fish_component:
					fish_component.enter_state(Fish.FishState.FISH_MERMAID)
			print_debug("Waiting for fishes to be gone...")
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

func _on_game_entered_state(new_state: Play.GameStates):
	match new_state:
		Play.GameStates.GAME_NORMAL:
			enter_state(SpawnerState.SPAWNER_NORMAL)
		Play.GameStates.GAME_MERMAID:
			enter_state(Spawner.SpawnerState.SPAWNER_MERMAID)
		_:
			pass
