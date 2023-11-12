class_name Typeable
extends CharacterBody2D

signal typeable_caught(fish_size: TypeableSize, base_point_value: int)

enum TypeableSize {
		SMALL,
		MEDIUM,
		LARGE
}

@export var fish_size: TypeableSize
@export var base_point_value: int

@export var min_velocity_multiplier: float = 1.0
@export var max_velocity_multiplier: float = 1.0
@export var fish_velocity: Vector2

@export var sprite_speed: float :
	set (value):
		if (is_node_ready()):
			$TypeableAnimationTree["parameters/TimeScale/scale"] = value	# Reflect the time scale of the sprite animation to this value
		sprite_speed = value
	get:
		return sprite_speed

var word: String :
	set (value):
		word = value
		$TypeableWord.text = word;
	get:
		return word

# Called when the node enters the scene tree for the first time.
func _ready():
	$TypeableAnimationTree["parameters/TimeScale/scale"] = sprite_speed
	velocity = fish_velocity * randf_range(min_velocity_multiplier, max_velocity_multiplier)

func _physics_process(_delta):
	move_and_slide()
	return

func highlight_word(end: int):
	var fish_word_label: RichTextLabel = $TypeableWord
	fish_word_label.remove_paragraph(0)
	fish_word_label.push_color(Color.YELLOW)
	fish_word_label.append_text(word.substr(0, end))
	fish_word_label.pop()
	fish_word_label.append_text(word.substr(end, -1))

func reset_text():
	var fish_word_label: RichTextLabel = $TypeableWord
	fish_word_label.remove_paragraph(0)
	fish_word_label.append_text(word)

func _on_current_word_changed(current_word: String):
	if word == current_word:
		typeable_caught.emit(fish_size, base_point_value)
		get_parent().queue_free()
		return

	if word.begins_with(current_word):
		highlight_word(current_word.length())
	else:
		reset_text()
	return
