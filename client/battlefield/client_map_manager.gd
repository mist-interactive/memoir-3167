class_name ClientMapManager

extends Node

@export var map_ground_layer: HexagonTileMapLayer
@export var map_features_layer: HexagonTileMapLayer
@export var unit_container: Node
@export var unit_scene: PackedScene
@onready var battlefield_state: BattlefieldState = $"../../BattlefieldState"
@onready var hand_ui: PlayerHandUI = $"../UICanvas/MarginContainer/PlayerHandUI"
@onready var enemy_hand_ui: EnemyHandUI = $"../UICanvas/MarginContainer2/EnemyHandUI"

func setup_hand_ui(player_ids: Array[int]) -> void:
	hand_ui.initialize()
	enemy_hand_ui.initialize(player_ids[0])

var GROUND_TO_TILE: Dictionary = {}
var FEATURE_TO_TILE: Dictionary = {}

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
	var filepath: String = "res://maps/" + map_name
	print("Client loading map ", map_name)
	if not FileAccess.file_exists(filepath):
		push_error("No such map file: ", filepath)
		return
	var file := FileAccess.open(filepath, FileAccess.READ)
	var json_string: String = file.get_as_text()
	file.close()
	var map_data = JSON.parse_string(json_string)
	if typeof(map_data) != TYPE_DICTIONARY:
		push_error("Map file is corruct or not formatted as a Dictionary")
		return
	print("Map file parsed succesfully. Reconstructing map...")
	map_ground_layer.clear()
	map_features_layer.clear()
	_parse_hex_data(map_data)
	_parse_unit_data(map_data)
	print("Map reconstruction complete!")
	map_loaded.emit()
	pass
	
func _parse_hex_data(map_data: Dictionary) -> void:
	var hex_array: Array = map_data.get("hexes", [])
	for cell_dict in hex_array:
		var coord: Vector2i = HexCell._parse_coord(cell_dict, "coord")
		var ground_type: int = cell_dict.get("ground")
		if GROUND_TO_TILE.has(ground_type):
			var tile_info: Array = GROUND_TO_TILE[ground_type]
			var source_id: int = tile_info[0]
			var atlas_coord: Vector2i = tile_info[1]
			map_ground_layer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Ground enum: ", ground_type)
		var feature_type: int = cell_dict.get("feature")
		if FEATURE_TO_TILE.has(feature_type):
			var tile_info: Array = FEATURE_TO_TILE[feature_type]
			var source_id: int = tile_info[0]
			var atlas_coord: Vector2i = tile_info[1]
			map_features_layer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Feature enum: ", feature_type)

func _parse_unit_data(map_data: Dictionary) -> void:
	var unit_array: Array = map_data.get("units", [])
	for unit_dict in unit_array:
		var coord_data: Array = unit_dict.get("coord", [0, 0])
		var grid_coord := Vector2i(coord_data[0], coord_data[1])
		var unit_type := int(unit_dict.get("type", 0)) as GameEnums.UnitType
		var unit_owner := int(unit_dict.get("owner_id", 1))
		var unit_instance := unit_scene.instantiate() as Unit
		unit_container.add_child(unit_instance)
		unit_instance.setup(unit_owner, unit_type, map_ground_layer)
		unit_instance.hex_coord = grid_coord
		unit_instance.position = map_ground_layer.map_to_local(grid_coord)
	pass
