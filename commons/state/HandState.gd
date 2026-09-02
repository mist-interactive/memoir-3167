extends Node
class_name HandState

var card_ids: Dictionary[int, String]:
	set(new_card_ids):
		card_ids = new_card_ids
		should_sync = true
var discard_pile: Array[CardInstance]:
	set(new_pile):
		should_sync = true
		discard_pile = new_pile

var opponent_hand_size: int = 0:
	set(new_hand_size):
		opponent_hand_size = new_hand_size
		should_sync = true
var is_hand_drawn: bool = false
var should_sync: bool = true

func _ready() -> void:
	name = "HandState"

func get_snapshot() -> Dictionary:
	var packed_discard_pile: Array
	for card: CardInstance in discard_pile:
		packed_discard_pile.append(card.to_dict())
	return {
		"card_ids": self.card_ids,
		"opponent_hand_size": self.opponent_hand_size,
		"discard_pile": packed_discard_pile
	}

func add_card(instance_id: int, card_id: String) -> void:
	card_ids[instance_id] = card_id
	should_sync = true

func remove_card(instance_id: int) -> void:
	card_ids.erase(instance_id)
	should_sync = true
