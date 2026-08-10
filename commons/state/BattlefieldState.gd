extends Node
class_name BattlefieldState
var map: Dictionary[Vector2i, HexCell]
var units_to_spawn_player_1: Array[Dictionary]
var units_to_spawn_player_2: Array[Dictionary]
var left_sector_max: int
var right_sector_min: int
var loaded: bool
var mapName: String
## Dictionary mapping each Sector enum to an Array[Vector2i] of coordinates.
var sector_index: Dictionary[enums.Sector, Array] = {
	enums.Sector.LEFT: [] as Array[Vector2i],
	enums.Sector.CENTER: [] as Array[Vector2i],
	enums.Sector.RIGHT: [] as Array[Vector2i]
}

## Rebuilds the sector lookup table from the current map state.
func build_sector_index() -> void:
	# 1. Clear existing coordinates without breaking inner array typing
	for sector_key: enums.Sector in sector_index:
		(sector_index[sector_key] as Array).clear()

	# 2. Iterate through all key-value pairs in the map
	for coords: Vector2i in map:
		var cell: HexCell = map[coords]
		if not cell or cell.sector == enums.Sector.NONE:
			continue

		# 3. Check bit flags using bitwise AND
		if cell.sector & enums.Sector.LEFT != 0:
			(sector_index[enums.Sector.LEFT] as Array).append(coords)
			
		if cell.sector & enums.Sector.CENTER != 0:
			(sector_index[enums.Sector.CENTER] as Array).append(coords)
			
		if cell.sector & enums.Sector.RIGHT != 0:
			(sector_index[enums.Sector.RIGHT] as Array).append(coords)

func _init(mapName: String) -> void:
	name = "BattlefieldState"
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
	if !parsed_data is Dictionary:
		push_error("Expected a JSON Array `[]` at the root, but got something else.")
		return false

	map.clear()
	if "sectors" in parsed_data:
		left_sector_max = parsed_data["sectors"]["left_sector_max"]
		right_sector_min = parsed_data["sectors"]["right_sector_min"]
	for elem in parsed_data["hexes"]:
		if elem is Dictionary:
			var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
			var cell: HexCell = HexCell.new(coord, elem.ground, elem.feature)
			map[coord] = cell
	for elem in parsed_data["units"]:
		if elem is Dictionary:
			if elem.owner_id == 1:
				units_to_spawn_player_1.append(elem)
			elif elem.owner_id == 2:
				units_to_spawn_player_2.append(elem)
	print("Successfully parsed and loaded map: ", mapName, ",size: ", map.size())
	return true
