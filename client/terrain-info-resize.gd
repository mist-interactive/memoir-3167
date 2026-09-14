extends TextureRect

const DEFAULT_POSITION = 128
const NEW_POSITION = DEFAULT_POSITION * 2
const DEFAULT_SCALE = Vector2(1.0, 1.0)
const NEW_SCALE = Vector2(10, 10)

func resize()-> void:
	position.x = NEW_POSITION
	scale = NEW_SCALE

func restore() -> void:
	position.x = DEFAULT_POSITION
	scale = DEFAULT_SCALE
