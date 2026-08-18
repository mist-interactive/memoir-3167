extends TextureProgressBar

@export var unit: Unit

func _ready() -> void:
	var tile_scale = HexMetrics.tile_width / HexMetrics.HEX_SIZE
	scale = Vector2(tile_scale / 2, tile_scale)
	position = unit.hex_coord + Vector2i(-HexMetrics.tile_width, -HexMetrics.tile_height / 2.0)
