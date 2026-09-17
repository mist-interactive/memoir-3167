class_name UnitData
extends RefCounted
const DEFAULT_ACTIONS: enums.UnitActions = enums.UnitActions.CAN_MOVE | enums.UnitActions.CAN_ATTACK

var owner_id: enums.Side
var uuid: int = -1
var hit_point: int:
	set(new_hp):
		hit_point = new_hp
		isDirty = true
var hex_coord: Vector2i:
	set(new_coord):
		hex_coord = new_coord
		isDirty = true
var type: enums.UnitType
var actions: enums.UnitActions = DEFAULT_ACTIONS:
	set(new_val):
		actions = new_val
var num_of_retreat: int = -1:
	set(new_val):
		num_of_retreat = new_val
		isDirty = true
var isDirty: bool = false

func _init(owner_id: enums.Side, type: int, id: int, coord: Vector2i) -> void:
	self.uuid = id
	self.hex_coord = coord
	self.type = type
	self.owner_id = owner_id
	self.hit_point = UnitDatabase.get_stats(type).max_health

func get_snapshot() -> Dictionary:
	return {
		"uuid": uuid,
		"hex_coord": hex_coord,
		"type": type,
		"owner_id": owner_id,
		"hit_point": hit_point,
		"actions": actions,
		"num_of_retreat": num_of_retreat
	}

func sync(peer_ids: Array[int]) -> void:
	if !isDirty:
		return
	Network.broadcast(Network.Units.sync_unit.rpc_id, peer_ids, [get_snapshot()])
	isDirty = false

func is_my_unit(side: enums.Side) -> bool:
	return owner_id == side

func unset_all() -> void:
	actions = DEFAULT_ACTIONS

func set_selected(value: bool) -> void:
	if value:
		actions |= enums.UnitActions.IS_SELECTED
	else:
		actions &= ~enums.UnitActions.IS_SELECTED

func set_can_move(value: bool) -> void:
	if value:
		actions |= enums.UnitActions.CAN_MOVE
	else:
		actions &= ~enums.UnitActions.CAN_MOVE

func set_can_attack(value: bool) -> void:
	if value:
		actions |= enums.UnitActions.CAN_ATTACK
	else:
		actions &= ~enums.UnitActions.CAN_ATTACK

func set_must_retreat(value: bool) -> void:
	if value:
		actions |= enums.UnitActions.MUST_RETREAT
	else:
		actions &= ~enums.UnitActions.MUST_RETREAT

func is_selected() -> bool:
	return (actions & enums.UnitActions.IS_SELECTED) != 0

func can_move() -> bool:
	return (actions & enums.UnitActions.CAN_MOVE) != 0

func can_attack() -> bool:
	return (actions & enums.UnitActions.CAN_ATTACK) != 0

func must_retreat() -> bool:
	return (actions & enums.UnitActions.MUST_RETREAT) != 0
