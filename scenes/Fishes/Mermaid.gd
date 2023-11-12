class_name Mermaid extends Node2D

signal mermaid_over()

@onready var mermaid_sprite: Sprite2D = get_node("%MermaidSprite")

func appear() -> void:
	mermaid_sprite.visible = true

	var tween = create_tween()
	var set_flash_progress: Callable = func (current_progress: float):
		mermaid_sprite.material.set_shader_parameter(&"flash_progress", current_progress)
	tween.tween_method(set_flash_progress, 1.0, 0.0, 0.5).set_trans(Tween.TRANS_SINE)

	return


func disappear() -> void:

	var tween = create_tween()
	var set_flash_progress: Callable = func (current_progress: float):
		mermaid_sprite.material.set_shader_parameter(&"flash_progress", current_progress)
	tween.tween_method(set_flash_progress, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
	
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	appear()
	return

func _on_mermaid_timer_timeout():
	mermaid_over.emit()
	call_deferred(&"disappear")
	

