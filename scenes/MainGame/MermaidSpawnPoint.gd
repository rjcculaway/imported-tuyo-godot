@tool
extends Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		var mermaid = preload("res://scenes/Fishes/Mermaid/Mermaid.tscn").instantiate()

		(mermaid.get_node("%MermaidSprite") as Sprite2D).modulate = Color.from_ok_hsl(1.0, 1.0, 1.0, 0.5)

		add_child(mermaid)
