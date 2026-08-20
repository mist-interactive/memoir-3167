@tool

extends Node

@export var MapGroundLayer: HexagonTileMapLayer
@export var MapFeatureLayer: HexagonTileMapLayer
@export var UnitContainer: Node2D
@export var MapName: String

var _map_width: int
var _map_height: int
var _left_max_x: int
var _right_min_x: int

# Check box "button" to bake map on inspector
@export var bake_map: bool = false:
	set(value):
		if value == true:
			if is_inside_tree():
				_bake_map()
		bake_map = false

func save_to_file(content: String) -> void:
	var file_name = "res://maps/" + MapName + ".json"
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if file:
		print("Saving map to a file")
		file.store_string(content)
	else:
		push_error("Could not open file. Does the 'maps' folder exist?")
	pass

func _bake_map() -> void:
	print("Start baking the map")
	if MapGroundLayer == null:
		push_error("MapGroundLayer is not assigned!")
		return
	var map_data: Dictionary = {
		"width": -1,
		"height": -1,
		"hexes": [],
		"units": [],
		"sectors": [],
	}
	_calculate_map_boundaries()
	map_data["width"] = _map_width
	map_data["height"] = _map_height
	map_data["hexes"] = _get_hex_data()
	map_data["units"] = _get_unit_data()
	map_data["sectors"] = _get_map_boundaries()
	var map_json_string: String = JSON.stringify(map_data, "\t")
	save_to_file(map_json_string)
	pass

func _get_hex_data() -> Array[Dictionary]:
	var hex_data: Array[Dictionary]
	var used_cells: Array[Vector2i] = MapGroundLayer.get_used_cells()
	if used_cells.is_empty():
		print("The map is empty. Nothing to bake.")
		return []
	print("Found ", used_cells.size(), " tiles. Baking...")
	for coord in used_cells:
		# Get the ground type
		var ground_source_id: int = MapGroundLayer.get_cell_source_id(coord)
		var ground_atlas_coords: Vector2i = MapGroundLayer.get_cell_atlas_coords(coord)
		var ground_key: Array = [ground_source_id, ground_atlas_coords]
		var final_ground: int
		if MapData.GROUND_ATLAS.has(ground_key):
			final_ground = MapData.GROUND_ATLAS[ground_key]
		else:
			push_warning("Found an unknown ground tile at ", coord)

		# Get the feature type (if any)
		var feature_source_id: int = MapFeatureLayer.get_cell_source_id(coord)
		var feature_atlas_coords: Vector2i = MapFeatureLayer.get_cell_atlas_coords(coord)
		var feature_key: Array = [feature_source_id, feature_atlas_coords]
		var final_feature: int
		if MapData.FEATURE_ATLAS.has(feature_key):
			final_feature = MapData.FEATURE_ATLAS[feature_key]
		elif final_ground == HexCell.Ground.WATER:
			final_feature = HexCell.Feature.WATER
		else:
			final_feature = HexCell.Feature.NONE
		var sector = _get_hex_sector(coord)
		var temp_hex = HexCell.new(coord, final_ground, final_feature, sector)
		if temp_hex.feature == HexCell.Feature.HILL:
			temp_hex.elevation = 2.0
		hex_data.append(temp_hex.serialize())
	return hex_data

func _get_unit_data() -> Array[Dictionary]:
	var unit_data: Array[Dictionary]
	var count: int = 0
	for child in UnitContainer.get_children():
		if not child is UnitSpawnMarker:
			continue
		var pos := MapGroundLayer.local_to_map(child.position)
		unit_data.append(child.serialize(pos))
		count += 1
	return unit_data

func _calculate_map_boundaries() -> void:
	var used_rect: Rect2i = MapGroundLayer.get_used_rect()
	_map_width = used_rect.size.x
	_map_height = used_rect.size.y
	var sector_width: int = _map_width / 3
	_left_max_x = used_rect.position.x + sector_width - 1
	_right_min_x = used_rect.end.x - sector_width

func _get_map_boundaries() -> Dictionary:
	return {
		"left_sector_max": _left_max_x,
		"right_sector_min": _right_min_x
	}

func _get_hex_sector(coord: Vector2i) -> int:
	var is_odd_row: bool = (coord.y % 2 != 0)
	var right_straddle_col: int = _right_min_x - 1
	if coord.x < _left_max_x:
		return enums.MapSector.LEFT
	elif coord.x == _left_max_x:
		if is_odd_row:
			return enums.MapSector.LEFT | enums.MapSector.CENTER
		else:
			return enums.MapSector.LEFT
	elif coord.x < right_straddle_col:
		return enums.MapSector.CENTER
	elif coord.x == right_straddle_col:
		if is_odd_row:
			return enums.MapSector.CENTER | enums.MapSector.RIGHT
		else:
			return enums.MapSector.CENTER
	else:
		return enums.MapSector.RIGHT
