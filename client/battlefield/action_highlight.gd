@tool

extends HexagonTileMapLayer

func _ready() -> void:
	pass

func highlight_cell(coord: Vector2i, atlas_coordinate: Vector2i = Vector2i(0, 0)) -> void:
	set_cell(coord, 2, atlas_coordinate)
