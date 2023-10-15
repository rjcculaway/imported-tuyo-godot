extends Sprite2D

@export var animation_tree: AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	return
