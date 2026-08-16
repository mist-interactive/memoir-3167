class_name ClientMapManager

extends Node

@export var map_ground_layer: HexagonTileMapLayer
@export var map_features_layer: HexagonTileMapLayer
@export var map_highlight_layer: HexagonTileMapLayer
@export var map_visuals_node: Node
@export var unit_container: Node
@export var unit_scene: PackedScene
@export var left_sector_divider: Line2D
@export var right_sector_divider: Line2D
@onready var battlefield_state: BattlefieldState = $"../../BattlefieldState"
@onready var hand_ui: PlayerHandUI = $"../UICanvas/MarginContainer/PlayerHandUI"
@onready var enemy_hand_ui: EnemyHandUI = $"../UICanvas/MarginContainer2/EnemyHandUI"

var sector_index: Dictionary[enums.MapSector, Array] = {
	enums.MapSector.LEFT: [] as Array[Vector2i],
	enums.MapSector.CENTER: [] as Array[Vector2i],
	enums.MapSector.RIGHT: [] as Array[Vector2i]
}

var GROUND_TO_TILE: Dictionary = {}
var FEATURE_TO_TILE: Dictionary = {}

var map: HexGrid
#var map: Dictionary[Vector2i, HexCell]
var left_sector_max: int = -1
var right_sector_min: int = -1

signal map_loaded

func _ready() -> void:
	# Automatically invert the dictionaries from MapData for fast lookups on the client.
	for key in MapData.GROUND_ATLAS:
		var enum_value = MapData.GROUND_ATLAS[key]
		GROUND_TO_TILE[enum_value] = key
		
	for key in MapData.FEATURE_ATLAS:
		var enum_value = MapData.FEATURE_ATLAS[key]
		FEATURE_TO_TILE[enum_value] = key
	call_deferred("load_map", (battlefield_state.mapName))

func load_map(map_name: String) -> void:
	parseAndLoadMap(map_name)
	_load_map_data_to_tilemap_layers()
	_draw_sector_dividers()
	_offset_map_to_hex_grid()
	map_loaded.emit()
	pass

func _offset_map_to_hex_grid() -> void:
	var visual_center = map_ground_layer.map_to_local(Vector2i.ZERO)
	var math_center = HexGrid.offset_to_pixel(Vector2i.ZERO)
	var offset = math_center - visual_center
	map_visuals_node.position += offset

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
	var map_width = int(parsed_data.get("width"))
	var map_height = int(parsed_data.get("height"))
	map = HexGrid.new(map_width, map_height)
	map.cells.clear()

	# 1. Parse Sector Boundaries
	if "sectors" in parsed_data and parsed_data["sectors"] is Dictionary:
		left_sector_max = int(parsed_data["sectors"].get("left_sector_max", 0))
		right_sector_min = int(parsed_data["sectors"].get("right_sector_min", 0))

	# 2. Parse Hexes & Determine Sector Bit Flags
	if "hexes" in parsed_data and parsed_data["hexes"] is Array:
		for elem in parsed_data["hexes"]:
			if not elem is Dictionary:
				continue
			
			var coord_arr: Array = elem.get("coord", [0, 0])
			var coord := Vector2i(int(coord_arr[0]), int(coord_arr[1]))
			var cell := HexCell.new(coord, elem.get("ground", 0), elem.get("feature", 0), elem.get("sector", 0))
			map.cells[coord] = cell

	# 4. Rebuild Sector Lookup Table
	build_sector_index()

	print("Successfully parsed and loaded map: %s (%d hexes indexed)." % [map_name, map.cells.size()])
	return true

func _load_map_data_to_tilemap_layers() -> void:
	map_ground_layer.clear()
	map_features_layer.clear()
	for coord in map.cells:
		var hex: HexCell = map.cells[coord]
		var ground_type: int = hex.ground
		if GROUND_TO_TILE.has(ground_type):
			var tile_info: Array = GROUND_TO_TILE[ground_type]
			var source_id: int = tile_info[0]
			var atlas_coord: Vector2i = tile_info[1]
			map_ground_layer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Ground enum: ", ground_type)
		var feature_type: int = hex.feature
		if FEATURE_TO_TILE.has(feature_type):
			var tile_info: Array = FEATURE_TO_TILE[feature_type]
			var source_id: int = tile_info[0]
			var atlas_coord: Vector2i = tile_info[1]
			map_features_layer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Feature enum: ", feature_type)
	pass

func _draw_sector_dividers() -> void:
	# 1. Determine the vertical bounds of the map in grid coordinates
	var used_rect: Rect2i = map_ground_layer.get_used_rect()
	var top_row: int = used_rect.position.y
	var bottom_row: int = used_rect.end.y - 1
	
	# Convert grid rows to pixel Y coordinates. 
	# We add/subtract an arbitrary pixel amount (e.g., 100) so the lines extend slightly past the grid.
	var line_top_y: float = map_ground_layer.map_to_local(Vector2i(0, top_row)).y - (map.tile_half_height)
	var line_bottom_y: float = map_ground_layer.map_to_local(Vector2i(0, bottom_row)).y + (map.tile_half_height)
	
	# 2. Calculate the Left and Right Divider X Coordinate
	var left_pure_hex_pos := map_ground_layer.map_to_local(Vector2i(left_sector_max, 0))
	var left_center_adj_hex_pos := map_ground_layer.map_to_local(Vector2i(left_sector_max + 1, 0))
	var left_line_x: float = (left_pure_hex_pos.x + left_center_adj_hex_pos.x) / 2.0
	
	var right_pure_hex_pos := map_ground_layer.map_to_local(Vector2i(right_sector_min, 0))
	var right_center_adj_hex_pos := map_ground_layer.map_to_local(Vector2i(right_sector_min - 1, 0))
	var right_line_x: float = (right_pure_hex_pos.x + right_center_adj_hex_pos.x) / 2.0
	
	# 4. Apply the coordinates to the Line2D nodes
	left_sector_divider.clear_points()
	left_sector_divider.add_point(Vector2(left_line_x, line_top_y))
	left_sector_divider.add_point(Vector2(left_line_x, line_bottom_y))
	
	right_sector_divider.clear_points()
	right_sector_divider.add_point(Vector2(right_line_x, line_top_y))
	right_sector_divider.add_point(Vector2(right_line_x, line_bottom_y))

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
