extends Node
class_name MapData

const GROUND_SPRITE_SHEET_ID := 1
const FEATURE_SPRITE_SHEET_ID := 1

const GROUND_ATLAS: Dictionary = {
	[GROUND_SPRITE_SHEET_ID, Vector2i(0, 0)]: HexCell.Ground.PLAINS,
	[GROUND_SPRITE_SHEET_ID, Vector2i(1, 0)]: HexCell.Ground.HEDGEROW,
	[GROUND_SPRITE_SHEET_ID, Vector2i(2, 0)]: HexCell.Ground.FOREST,
	[GROUND_SPRITE_SHEET_ID, Vector2i(3, 0)]: HexCell.Ground.TOWN,
	[GROUND_SPRITE_SHEET_ID, Vector2i(4, 0)]: HexCell.Ground.HILL,
	[GROUND_SPRITE_SHEET_ID, Vector2i(5, 0)]: HexCell.Ground.MOUNTAIN,
	[GROUND_SPRITE_SHEET_ID, Vector2i(6, 0)]: HexCell.Ground.WATER,

}
const FEATURE_ATLAS: Dictionary = {
}
