class_name Fish
extends CharacterBody2D

signal fish_caught(fish_size: FishSize, base_point_value: int)

enum FishSize {
		SMALL,
		MEDIUM,
		LARGE
}

@export var typeable: Typeable
@export var fish_size: FishSize
@export var base_point_value: int

@export var min_velocity_multiplier: float = 1.0
@export var max_velocity_multiplier: float = 1.0
@export var fish_velocity: Vector2

@export var sprite_speed: float :
	set (value):
		if (is_node_ready()):
			$FishAnimationTree["parameters/TimeScale/scale"] = value	# Reflect the time scale of the sprite animation to this value
		sprite_speed = value
	get:
		return sprite_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	$FishAnimationTree["parameters/TimeScale/scale"] = sprite_speed
	typeable.connect(&"typed_word_same", _on_typed_word_same)
	velocity = fish_velocity * randf_range(min_velocity_multiplier, max_velocity_multiplier)

func _physics_process(_delta):
	move_and_slide()
	return

func _on_typed_word_same():
	fish_caught.emit(fish_size, base_point_value)
	get_parent().queue_free()
