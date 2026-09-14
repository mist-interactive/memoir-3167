extends Node
class_name MapData

const PLAINS_SPRITE_SHEET_ID := 0
const PLAINS_DECOR_SHEET_ID := 0

const GROUND_ATLAS: Dictionary = {
	[PLAINS_SPRITE_SHEET_ID, Vector2i(0, 0)]: HexCell.Ground.PLAINS,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(1, 0)]: HexCell.Ground.HEDGEROW,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(2, 0)]: HexCell.Ground.FOREST,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(3, 0)]: HexCell.Ground.TOWN,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(4, 0)]: HexCell.Ground.HILL,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(5, 0)]: HexCell.Ground.MOUNTAIN,
	[PLAINS_SPRITE_SHEET_ID, Vector2i(6, 0)]: HexCell.Ground.WATER,

}
const FEATURE_ATLAS: Dictionary = {
}
