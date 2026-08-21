extends Node
class_name BattlefieldState

var map: HexGrid
var units_to_spawn_player_1: Array[Dictionary]
var units_to_spawn_player_2: Array[Dictionary]
var left_sector_max: int
var right_sector_min: int
var loaded: bool
var mapName: String = ""

## Dictionary mapping each Sector enum to an Array[Vector2i] of coordinates.
var sector_index: Dictionary[enums.MapSector, Array] = {
	enums.MapSector.LEFT: [] as Array[Vector2i],
	enums.MapSector.CENTER: [] as Array[Vector2i],
	enums.MapSector.RIGHT: [] as Array[Vector2i]
}

## Rebuilds the sector lookup table from the current map state.
func build_sector_index() -> void:
	# 1. Clear existing coordinates without breaking inner array typing
	for sector_key: enums.MapSector in sector_index:
		(sector_index[sector_key] as Array).clear()

	# 2. Iterate through all key-value pairs in the map
	for coords: Vector2i in map.cells:
		var cell: HexCell = map.cells[coords]
		if not cell or cell.sector == enums.MapSector.NONE:
			continue

		# 3. Check bit flags using bitwise AND
		if cell.sector & enums.MapSector.LEFT != 0:
			(sector_index[enums.MapSector.LEFT] as Array).append(coords)
			
		if cell.sector & enums.MapSector.CENTER != 0:
			(sector_index[enums.MapSector.CENTER] as Array).append(coords)
			
		if cell.sector & enums.MapSector.RIGHT != 0:
			(sector_index[enums.MapSector.RIGHT] as Array).append(coords)

func _init(mapName: String) -> void:
	name = "BattlefieldState"
	self.mapName = mapName
	loaded = parseAndLoadMap(mapName)

## Reads a JSON map file from res://maps/, populates the map dictionary,
## assigns sectors to hex cells, and builds the sector lookup table.
func parseAndLoadMap(map_name: String) -> bool:
	var src: String = "res://maps/%s" % map_name
	
	if not FileAccess.file_exists(src):
		push_error("Map file not found: " + src)
		return false

	var file := FileAccess.open(src, FileAccess.READ)
	if not file:
		push_error("Failed to open map file: " + src)
		return false

	var json_string: String = file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(json_string)
	if not parsed_data is Dictionary:
		push_error("Invalid map format in '%s'. Expected root Dictionary." % map_name)
		return false

	# Clear previous map state
	units_to_spawn_player_1.clear()
	units_to_spawn_player_2.clear()

	# 1. Parse Sector Boundaries
	if "sectors" in parsed_data and parsed_data["sectors"] is Dictionary:
		left_sector_max = int(parsed_data["sectors"].get("left_sector_max", 0))
		right_sector_min = int(parsed_data["sectors"].get("right_sector_min", 0))

	# 2. Parse Hexes & Determine Sector Bit Flags
	if "hex_grid" in parsed_data and parsed_data["hex_grid"] is Dictionary:
		map = HexGrid.deserialize(parsed_data["hex_grid"])

	# 3. Parse Starting Unit Deployments
	if "units" in parsed_data and parsed_data["units"] is Array:
		for elem in parsed_data["units"]:
			if not elem is Dictionary:
				continue
			var owner_id: int = int(elem.get("owner_id", 0))
			if owner_id == 1:
				units_to_spawn_player_1.append(elem)
			elif owner_id == 2:
				units_to_spawn_player_2.append(elem)

	# 4. Rebuild Sector Lookup Table
	build_sector_index()

	print("Successfully parsed and loaded map: %s (%d hexes indexed)." % [map_name, map.cells.size()])
	return true

func is_hex_in_map_sector(hex: Vector2i, sector: enums.MapSector) -> bool:
	return sector_index[sector].find(hex) > 0
