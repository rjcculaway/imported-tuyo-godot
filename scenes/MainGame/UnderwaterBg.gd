extends Sprite2D

const SCROLL_SPEED: float = 69.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	self.region_rect.position.y += SCROLL_SPEED * delta
	return
