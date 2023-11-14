@tool
extends Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		var mermaid = preload("res://scenes/Fishes/Mermaid/Mermaid.tscn").instantiate()
		add_child(mermaid)
