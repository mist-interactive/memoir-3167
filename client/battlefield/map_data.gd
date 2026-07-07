extends Node
class_name MapData

const FIELDS_SPRITE_SHEET_ID := 0
const FIELDS_DECOR_SHEET_ID := 0

const GROUND_ATLAS: Dictionary = {
	[FIELDS_SPRITE_SHEET_ID, Vector2i(0, 0)]: HexCell.Ground.FIELDS,
	[FIELDS_SPRITE_SHEET_ID, Vector2i(1, 0)]: HexCell.Ground.SAND,
	[FIELDS_SPRITE_SHEET_ID, Vector2i(2, 0)]: HexCell.Ground.WATER,

}
const FEATURE_ATLAS: Dictionary = {
	[FIELDS_DECOR_SHEET_ID, Vector2i(0, 0)]: HexCell.Feature.HILL,
	[FIELDS_DECOR_SHEET_ID, Vector2i(1, 0)]: HexCell.Feature.MOUNTAIN,
	[FIELDS_DECOR_SHEET_ID, Vector2i(1, 0)]: HexCell.Feature.ROCKS,
	[FIELDS_DECOR_SHEET_ID, Vector2i(1, 1)]: HexCell.Feature.FOREST,
}

var GROUND_TO_TILE: Dictionary
var FEATURE_TO_TILE: Dictionary

func _ready() -> void:
	# Automatically invert the dictionaries from MapData for fast lookups on the client.
	for key in MapData.GROUND_ATLAS:
		var enum_value = MapData.GROUND_ATLAS[key]
		GROUND_TO_TILE[enum_value] = key
		
	for key in MapData.FEATURE_ATLAS:
		var enum_value = MapData.FEATURE_ATLAS[key]
		FEATURE_TO_TILE[enum_value] = key
