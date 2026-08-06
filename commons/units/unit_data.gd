class_name UnitData
extends RefCounted

var owner_id: int
var uuid: int
var hex_coord: Vector2i
var type: GameEnums.UnitType

func _init(owner_id: int, type: int, id: int, coord: Vector2i) -> void:
	self.uuid = id
	self.hex_coord = coord
	self.type = type
	self.owner_id = owner_id
