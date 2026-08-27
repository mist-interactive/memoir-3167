extends Node

@export var registered_terrain: Array[TerrainStats] = []

var _db: Dictionary[HexCell.Feature, TerrainStats] = {}

func _ready() -> void:
	for stats in registered_terrain:
		if stats != null:
			_db[stats.type] = stats

func get_stats(terrain_type: HexCell.Feature) -> TerrainStats:
	if _db.has(terrain_type):
		return _db[terrain_type]
	push_error("TerrainDatabase: No stats found for UnitType %s " % terrain_type)
	return null
