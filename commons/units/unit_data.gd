class_name UnitData
extends RefCounted

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
		"hit_point": hit_point
	}

func sync(peer_ids: Array[int]) -> void:
	if !isDirty:
		return
	for peer_id in peer_ids:
		Network.Units.sync_unit.rpc_id(peer_id, get_snapshot())
	isDirty = false

func is_my_unit(side: enums.Side) -> bool:
	return owner_id == side
