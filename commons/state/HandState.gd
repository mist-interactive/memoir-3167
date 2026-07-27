extends Node
class_name HandState

var card_ids: Array[String]:
	set(new_card_ids):
		card_ids = new_card_ids
		should_sync = true

var should_sync: bool

func _ready() -> void:
	name = "HandState"
	Network.Hand.sync_requested.connect(_on_sync_requested)

func get_snapshot() -> Dictionary:
	return {
		"card_ids": self.card_ids
	}

func _on_sync_requested(snapshot: Dictionary):
	card_ids = snapshot.card_ids

func add_card(card_id: String) -> void:
	card_ids.append(card_id)
	should_sync = true
