class_name UnitData
extends RefCounted

var uuid: String
var hex_coord: Vector2i
var type: String

func _init(id: String, coord: Vector2i, type: String) -> void:
	uuid = id
	hex_coord = coord
	type = type
