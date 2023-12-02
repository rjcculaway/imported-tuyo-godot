class_name Fish
extends CharacterBody2D

signal fish_caught(node: Node2D, fish_size: FishSize, base_point_value: int)

enum FishSize {
		SMALL,
		MEDIUM,
		LARGE
}

enum FishState {
	TRANSITIONING,
	FISH_NORMAL,
	FISH_INACTIVE,
	FISH_CAUGHT,
}

@export var typeable: Typeable
@export var fish_size: FishSize
@export var base_point_value: int

@export var min_velocity_multiplier: float = 1.0
@export var max_velocity_multiplier: float = 1.0
@export var escaping_velocity: float = 240.0
@export var fish_velocity: Vector2

@export var sprite_speed: float :
	set (value):
		if (is_node_ready()):
			$FishAnimationTree["parameters/TimeScale/scale"] = value	# Reflect the time scale of the sprite animation to this value
		sprite_speed = value
	get:
		return sprite_speed

var current_state: FishState

func enter_state(next_state: FishState) -> void:
	exit_state(current_state)
	current_state = FishState.TRANSITIONING
	# print_debug("Transitioning to state: " + FishState.keys()[next_state])
	match next_state:
		FishState.FISH_NORMAL:
			$FishAnimationTree["parameters/TimeScale/scale"] = sprite_speed
			typeable.connect(&"typed_word_same", _on_typed_word_same)
			velocity = fish_velocity * randf_range(min_velocity_multiplier, max_velocity_multiplier)
			typeable.fade_in()
			$CollisionShape2D.disabled = false
		FishState.FISH_INACTIVE:
			$FishAnimationTree["parameters/TimeScale/scale"] = sprite_speed
			$Typeable.fade_out()
			velocity = Vector2(-escaping_velocity, 0.0)
		_:
			return
	current_state = next_state
	# print_debug("Entered state: " + FishState.keys()[current_state])
	return

func exit_state(exiting_state: FishState) -> void:
	# print_debug("Exiting fish state: " + FishState.keys()[exiting_state])
	match exiting_state:
		FishState.FISH_NORMAL:
			$FishAnimationTree["parameters/TimeScale/scale"] = 1.0
			typeable.disconnect(&"typed_word_same", _on_typed_word_same)
			velocity = Vector2(0.0, 0.0)
			typeable.fade_out.call_deferred()
			$CollisionShape2D.set_deferred("disabled", true)
		_:
			pass
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	enter_state(FishState.FISH_NORMAL)

func _physics_process(_delta):
	match current_state:
		FishState.FISH_CAUGHT:
			pass
		_:
			move_and_slide()
	return

func _on_typed_word_same():
	enter_state(FishState.FISH_CAUGHT)
	fish_caught.emit(get_parent(), fish_size, base_point_value)
