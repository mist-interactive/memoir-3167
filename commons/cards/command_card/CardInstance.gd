class_name CardInstance
extends RefCounted

var instance_id: int
var card_id: String

func _init(instance_id: int, card_id: String):
	self.instance_id = instance_id
	self.card_id = card_id

func to_dict() -> Dictionary:
	return {
		"instance_id": instance_id,
		"card_id": card_id
	}

static func from_dict(d: Dictionary) -> CardInstance:
	return CardInstance.new(d["instance_id"], d["card_id"])
