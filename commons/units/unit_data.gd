class_name UnitData
extends RefCounted

var owner_id: int # peer_id or uuid
var uuid: int = -1
var hex_coord: Vector2i:
	set(new_coord):
		hex_coord = new_coord
		isDirty = true
var type: enums.UnitType
var isDirty: bool = false

func _init(owner_id: int, type: int, id: int, coord: Vector2i) -> void:
	self.uuid = id
	self.hex_coord = coord
	self.type = type
	self.owner_id = owner_id

func get_snapshot() -> Dictionary:
	return {
		"uuid": uuid,
		"hex_coord": hex_coord,
		"type": type,
		"owner_id": owner_id
	}

func sync(peer_ids: Array[int]) -> void:
	if !isDirty:
		return
	for peer_id in peer_ids:
		Network.Units.sync_unit.rpc_id(peer_id, get_snapshot())
	isDirty = false
