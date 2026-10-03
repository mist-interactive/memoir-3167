@tool

extends HexagonTileMapLayer

func highlight_cell(coord: Vector2i) -> void:
	set_cell(coord, 0, Vector2i(0, 0))
