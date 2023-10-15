class_name Fish
extends CharacterBody2D

enum FishSize {
		SMALL,
		MEDIUM,
		LARGE
}

@export var fish_size: FishSize
@export var base_point_value: int
@export var fish_velocity: Vector2
@export var sprite_speed: float :
	set (value):
		if (is_node_ready()):
			$FishAnimationTree["parameters/TimeScale/scale"] = value	# Reflect the time scale of the sprite animation to this value
		sprite_speed = value
	get:
		return sprite_speed

# @onready var sprite_time_scale: Dictionary = animation_tree.set()

# Called when the node enters the scene tree for the first time.
func _ready():
	$FishAnimationTree["parameters/TimeScale/scale"] = sprite_speed
	velocity = fish_velocity
	

func _physics_process(_delta):
	move_and_slide()
	return	
