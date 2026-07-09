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
	[FIELDS_DECOR_SHEET_ID, Vector2i(0, 1)]: HexCell.Feature.ROCKS,
	[FIELDS_DECOR_SHEET_ID, Vector2i(1, 1)]: HexCell.Feature.FOREST,
}
