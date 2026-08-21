extends TextureProgressBar

@export var unit: Unit

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pivot_offset = size / 2.0
	var tile_scale = HexMetrics.tile_width / HexMetrics.HEX_SIZE
	scale = Vector2(tile_scale / 2.0, tile_scale)
	position.y = -HexMetrics.half_height
