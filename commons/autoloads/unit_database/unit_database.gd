extends Node

@export var registered_units: Dictionary[enums.UnitType, UnitStats] = {}

var _db: Dictionary[enums.UnitType, UnitStats] = {}

func _ready() -> void:
	for stats in registered_units:
		if stats != null:
			_db[stats] = registered_units[stats]

func get_stats(unit_type: enums.UnitType) -> UnitStats:
	if _db.has(unit_type):
		return _db[unit_type]
	push_error("UnitDatabase: No stats found for UnitType %s " % unit_type)
	return null
