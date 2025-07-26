extends SubViewport

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_window().size
	self.size = screen_size
