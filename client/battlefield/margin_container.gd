extends MarginContainer

func _ready() -> void:
	var canvas_size: Vector2 = get_viewport_rect().size
	custom_maximum_size = Vector2(canvas_size.x / 1.5, canvas_size.y / 1.5)
	position.y = canvas_size.y
