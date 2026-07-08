extends Node
class_name Battlefield
var map: Dictionary[Vector2i, HexCell]
var loaded: bool
var mapName: String

func _init(mapName: String) -> void:
	name = "battlefield"
	self.mapName = mapName
	loaded = parseAndLoadMap(mapName)

func parseAndLoadMap(mapName: String) -> bool:
	var src: String = "res://maps/%s" % mapName
	var file = FileAccess.open(src, FileAccess.READ)
	# 1. Read the file
	if not file:
		push_error("File not found: " + src)
		return false
	var json_string = file.get_as_text()
	file.close() # Close file handle early
	var parsed_data = JSON.parse_string(json_string)
	if parsed_data == null:
		push_error("Failed to parse JSON or its empty")
		return false
	if !parsed_data is Array:
		push_error("Expected a JSON Array `[]` at the root, but got something else.")
		return false
	map.clear()
	for elem in parsed_data:
		if elem is Dictionary:
			var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
			var cell: HexCell = HexCell.new(coord, elem.ground, elem.feature)
			map[coord] = cell
	print("Successfully parsed and loaded map: ", mapName, ",size: ", map.size())
	return true
