class_name ServerBattlefield

extends Node
# Our memory map. Key = Vector2i, Value = HexCell
var map: Dictionary = {}

func load_map(filepath: String) -> void:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		push_error("Could not open map file at: ", filepath)
		return
	var map_data: Array[Dictionary]
	map = JSON.parse_string(file)
	for hex in map:
		map_data.append(hex)
	print("Map loaded! Total hexes in memory: ", map.size())
