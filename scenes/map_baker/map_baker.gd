@tool

extends Node

@export var map_ground_layer: HexagonTileMapLayer
@export var map_feature_layer: HexagonTileMapLayer
@export var unit_container: Node2D
@export var map_name: String

const hex_elevation: Dictionary[HexCell.Feature, float] = {
	HexCell.Feature.NONE: 1.0,
	HexCell.Feature.ROAD: 1.0,
	HexCell.Feature.PLAINS: 1.0,
	HexCell.Feature.FOREST: 2.0,
	HexCell.Feature.HILL: 3.0,
	HexCell.Feature.MOUNTAIN: 4.0,
	HexCell.Feature.ROCKS: 1.5,
	HexCell.Feature.WATER: 0,
}

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
	var file_name = "res://maps/" + map_name + ".json"
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if file:
		print("Saving map to a file")
		file.store_string(content)
	else:
		push_error("Could not open file. Does the 'maps' folder exist?")
	pass

func _bake_map() -> void:
	print("Start baking the map")
	if map_ground_layer == null:
		push_error("map_ground_layer is not assigned!")
		return
	_calculate_map_boundaries()
	var map_data: Dictionary = {}
	map_data["hex_grid"] = _get_hex_grid()
	map_data["units"] = _get_unit_data()
	map_data["sectors"] = _get_map_boundaries()
	var map_json_string: String = JSON.stringify(map_data, "\t")
	save_to_file(map_json_string)
	pass

func _get_hex_grid() -> Dictionary:
	var used_cells: Array[Vector2i] = map_ground_layer.get_used_cells()
	if used_cells.is_empty():
		print("The map is empty. Nothing to bake.")
		return {}
	print("Found ", used_cells.size(), " tiles. Baking...")
	var hex_grid = HexGrid.new(_map_width, _map_height)
	hex_grid.cells.clear()
	for coord in used_cells:
		# Get the ground type
		var ground_source_id: int = map_ground_layer.get_cell_source_id(coord)
		var ground_atlas_coords: Vector2i = map_ground_layer.get_cell_atlas_coords(coord)
		var ground_key: Array = [ground_source_id, ground_atlas_coords]
		var final_ground: int
		if MapData.GROUND_ATLAS.has(ground_key):
			final_ground = MapData.GROUND_ATLAS[ground_key]
		else:
			push_warning("Found an unknown ground tile at ", coord)

		# Get the feature type (if any)
		var feature_source_id: int = map_feature_layer.get_cell_source_id(coord)
		var feature_atlas_coords: Vector2i = map_feature_layer.get_cell_atlas_coords(coord)
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
		temp_hex.elevation = hex_elevation[temp_hex.feature]
		hex_grid.cells[coord] = temp_hex
	return hex_grid.serialize()

func _get_unit_data() -> Array[Dictionary]:
	var unit_data: Array[Dictionary]
	for child in unit_container.get_children():
		if not child is UnitSpawnMarker:
			continue
		var pos := map_ground_layer.local_to_map(child.position)
		unit_data.append(child.serialize(pos))
	return unit_data

func _calculate_map_boundaries() -> void:
	var used_rect: Rect2i = map_ground_layer.get_used_rect()
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
