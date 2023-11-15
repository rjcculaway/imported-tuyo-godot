class_name Bubble extends Node2D

signal bubble_popped(has_timed_out: bool, score: int)

@export var bubble_score: int = 10
@export var bubble_duration: float = 3.0

func _enter_tree():
	add_to_group("bubbles", true)

func _ready():
	%BubbleAnimationPlayer.play(&"bubble_idle")
	var timer: SceneTreeTimer = get_tree().create_timer(bubble_duration)
	timer.connect(&"timeout", _on_bubble_timeout)

func get_word(word_bank: Resource):
	var word = word_bank.get_short_word()
	$Typeable.word = word

func _on_typed_word_same():
	%BubbleTimer.stop()
	%BubbleAnimationPlayer.stop()
	bubble_popped.emit(true, bubble_score)
	%BubbleAnimationPlayer.play(&"bubble_explode")
	print_debug("Bubble was popped!")

func _on_bubble_timeout():
	%BubbleAnimationPlayer.stop()
	bubble_popped.emit(false, bubble_score)
	%BubbleAnimationPlayer.play(&"bubble_explode")
	print_debug("Bubble failed to be popped!")
