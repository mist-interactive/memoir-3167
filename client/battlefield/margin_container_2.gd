extends MarginContainer

var CARDSIZE = Vector2(140, 220)

func _ready() -> void:
	var canvas_size: Vector2 = get_viewport_rect().size
	custom_maximum_size = Vector2(canvas_size.x / 1.5, canvas_size.y / 1.5)
	position = Vector2(canvas_size.x / 2, CARDSIZE.y / 2)
