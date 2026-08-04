@tool

extends Node

@export var MapGroundLayer: HexagonTileMapLayer
@export var MapFeatureLayer: HexagonTileMapLayer
@export var UnitContainer: Node2D

# Check box "button" to bake map on inspector
@export var bake_map: bool = false:
	set(value):
		if value == true:
			if is_inside_tree():
				_bake_map()
		bake_map = false

func save_to_file(content: String) -> void:
	var file = FileAccess.open("res://maps/map.json", FileAccess.WRITE)
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
	var map_data: Array[Dictionary] = []
	var used_cells: Array[Vector2i] = MapGroundLayer.get_used_cells()
	if used_cells.is_empty():
		print("The map is empty. Nothing to bake.")
		return
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
		map_data.append(temp_hex.serialize())
	var map_json_string: String = JSON.stringify(map_data, "\t")
	save_to_file(map_json_string)
	pass
