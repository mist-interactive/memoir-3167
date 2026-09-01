class_name CardInstance
extends RefCounted

var instance_id: int
var card_id: String
var owner_side: enums.Side

func _init(instance_id: int, card_id: String, owner_side: enums.Side):
	self.instance_id = instance_id
	self.card_id = card_id
	self.owner_side = owner_side

func to_dict() -> Dictionary:
	return {
		"instance_id": instance_id,
		"card_id": card_id,
		"owner_side": owner_side
	}

static func from_dict(d: Dictionary) -> CardInstance:
	return CardInstance.new(d["instance_id"], d["card_id"], d["owner_side"])
