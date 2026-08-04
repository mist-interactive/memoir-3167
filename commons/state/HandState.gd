extends Node
class_name HandState

var card_ids: Dictionary[int, String]:
	set(new_card_ids):
		card_ids = new_card_ids
		should_sync = true

var opponent_hand_size: int:
	set(new_hand_size):
		opponent_hand_size = new_hand_size
		should_sync = true

var should_sync: bool

func _ready() -> void:
	name = "HandState"
	Network.Hand.sync_requested.connect(_on_sync_requested)

func get_snapshot() -> Dictionary:
	return {
		"card_ids": self.card_ids,
		"opponent_hand_size": self.opponent_hand_size,
	}

func _on_sync_requested(snapshot: Dictionary):
	card_ids = snapshot.card_ids
	opponent_hand_size = snapshot.opponent_hand_size

func add_card(instance_id: int, card_id: String) -> void:
	card_ids[instance_id] = card_id
	should_sync = true
