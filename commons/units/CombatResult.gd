extends RefCounted
class_name CombatResult
var target: enums.Side
var unit_ids: Dictionary[enums.Side, int]
var rolled_dices: Array[enums.RolledDice] = []
var dmg: int = 0
var retreat: int = 0

func _init() -> void:
	pass

func initialize(unit: UnitData, target: UnitData, rolled_dices: Array[enums.RolledDice]) -> void:
	self.target = target.owner_id
	self.unit_ids[target.owner_id] = target.uuid
	self.unit_ids[unit.owner_id] = unit.uuid
	self.rolled_dices = rolled_dices

func to_dict() -> Dictionary:
	return {
		"target": target,
		"unit_ids": unit_ids,
		"rolled_dices": rolled_dices,
		"dmg": dmg,
		"retreat": retreat
	}

static func from_dict(result_dict: Dictionary) -> CombatResult:
	var result: CombatResult = CombatResult.new()
	result.target = result_dict.target
	result.unit_ids = result_dict.unit_ids
	result.rolled_dices = result_dict.rolled_dices
	result.dmg = result_dict.dmg
	result.retreat = result_dict.retreat
	return result
