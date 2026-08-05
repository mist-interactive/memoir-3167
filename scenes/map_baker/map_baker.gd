@tool

extends Node

@export var MapGroundLayer: HexagonTileMapLayer
@export var MapFeatureLayer: HexagonTileMapLayer
@export var UnitContainer: Node2D
@export var MapName: String

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
		"hexes": [],
		"units": [],
		"sectors": {}
	}
	map_data["hexes"] = _get_hex_data()
	map_data["units"] = _get_unit_data()
	map_data["sectors"] = _get_map_sectors()
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
		else:
			final_feature = HexCell.Feature.NONE
		var temp_hex = HexCell.new(coord, final_ground, final_feature)
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
		print(child.unit_type)
		count += 1
	print(count, " units found")
	return unit_data

func _get_map_sectors() -> Dictionary:
	var used_rect: Rect2i = MapGroundLayer.get_used_rect()
	var map_width: int = used_rect.size.x
	var sector_width: int = map_width / 3
	return {
		"left_sector_max": used_rect.position.x + sector_width,
		"right_sector_min": (used_rect.end.x - 1) - sector_width
	}
