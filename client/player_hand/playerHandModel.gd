class_name PlayerHandModel
extends RefCounted

signal card_added(instance_id: int, card_id: String)
signal card_removed(instance_id: int)
signal hand_synchronized(hand_data: Dictionary) # { instance_id (int): card_id (String) }

var _cards: Dictionary = {}

func add_card(instance_id: int, card_id: String) -> void:
	print("Model: Adding instance %d (Type: %s)" % [instance_id, card_id])
	_cards[instance_id] = card_id
	card_added.emit(instance_id, card_id)

func remove_card(instance_id: int) -> void:
	if _cards.has(instance_id):
		_cards.erase(instance_id)
		card_removed.emit(instance_id)
	else:
		push_warning("Client Hand Model: Attempted to remove instance %d, but it was not found." % instance_id)

func sync_hand(hand_data: Dictionary) -> void:
	_cards.clear()
	_cards = hand_data.duplicate()
	hand_synchronized.emit(_cards)

func is_empty() -> bool:
	return _cards.is_empty()

func get_cards() -> Dictionary:
	return _cards
