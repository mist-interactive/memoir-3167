class_name ClientMapManager

extends Node

@export var MapGroundLayer: HexagonTileMapLayer
@export var MapFeaturesLayer: HexagonTileMapLayer
@onready var BattlefieldState: BattlefieldState = $"../../BattlefieldState"
@onready var hand_ui: PlayerHandUI = $"../UICanvas/MarginContainer/PlayerHandUI"
@onready var enemy_hand_ui: EnemyHandUI = $"../UICanvas/MarginContainer2/EnemyHandUI"

func setup_hand_ui(player_ids: Array[int]) -> void:
	hand_ui.initialize()
	enemy_hand_ui.initialize(player_ids[0])

var GROUND_TO_TILE: Dictionary = {}
var FEATURE_TO_TILE: Dictionary = {}

func _ready() -> void:
	# Automatically invert the dictionaries from MapData for fast lookups on the client.
	for key in MapData.GROUND_ATLAS:
		var enum_value = MapData.GROUND_ATLAS[key]
		GROUND_TO_TILE[enum_value] = key
		
	for key in MapData.FEATURE_ATLAS:
		var enum_value = MapData.FEATURE_ATLAS[key]
		FEATURE_TO_TILE[enum_value] = key
	load_map(BattlefieldState.mapName)

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
	MapGroundLayer.clear()
	MapFeaturesLayer.clear()
	_parse_hex_data(map_data)
	_parse_unit_data(map_data)
	print("Map reconstruction complete!")
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
			MapGroundLayer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Ground enum: ", ground_type)
		var feature_type: int = cell_dict.get("feature")
		if FEATURE_TO_TILE.has(feature_type):
			var tile_info: Array = FEATURE_TO_TILE[feature_type]
			var source_id: int = tile_info[0]
			var atlas_coord: Vector2i = tile_info[1]
			MapFeaturesLayer.set_cell(coord, source_id, atlas_coord)
		else:
			push_warning("Client doesn't have visual data for the Feature enum: ", feature_type)

func _parse_unit_data(map_data: Dictionary) -> void:
	pass
