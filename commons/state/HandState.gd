extends Node
class_name HandState

signal hand_drawn
signal card_drawn
signal card_played(instance_id: int, card_id: String)
signal enemy_hand_drawn
signal enemy_card_drawn
signal enemy_card_played(instance_id: int, card_id: String)

var card_ids: Dictionary[int, String]:
	set(new_card_ids):
		card_ids = new_card_ids
		should_sync = true
var discard_pile: Array[CardInstance]:
	set(new_pile):
		should_sync = true
		discard_pile = new_pile

var opponent_hand_size: int:
	set(new_hand_size):
		opponent_hand_size = new_hand_size
		should_sync = true

var should_sync: bool

func _ready() -> void:
	name = "HandState"
	Network.Hand.sync_requested.connect(_on_sync_requested)

func get_snapshot() -> Dictionary:
	var packed_discard_pile: Array
	for card: CardInstance in discard_pile:
		print(card)
		packed_discard_pile.append(card.to_dict())
	return {
		"card_ids": self.card_ids,
		"opponent_hand_size": self.opponent_hand_size,
		"discard_pile": packed_discard_pile
	}

func _on_sync_requested(snapshot: Dictionary):
	var events: Array[Event]
	
	if card_ids.size() == 0 && snapshot.card_ids.size() == 6:
		events.append(Event.new(hand_drawn))
	elif card_ids.size() > snapshot.card_ids.size():
		events.append(Event.new(card_drawn))
	
	if opponent_hand_size == 0 && snapshot.opponent_hand_size == 6:
		events.append(Event.new(enemy_hand_drawn))
	elif opponent_hand_size > snapshot.opponent_hand_size:
		events.append(Event.new(enemy_card_drawn))
	
	var new_discard_pile: Array[CardInstance]
	for packed in snapshot.discard_pile:
		new_discard_pile.append(CardInstance.from_dict(packed))
	
	if discard_pile.size() != new_discard_pile.size():
		var card: CardInstance = new_discard_pile.pop_back();
		var args: Array = [card.instance_id, card.card_id]
		var enemyPlayed: bool = not card_ids.has(card.instance_id)
		var event: Event = Event.new(enemy_card_played if enemyPlayed else card_played, args)
		events.append(event)
		
	card_ids = snapshot.card_ids
	discard_pile = new_discard_pile
	opponent_hand_size = snapshot.opponent_hand_size
	for event: Event in events:
		event.emit()

func add_card(instance_id: int, card_id: String) -> void:
	card_ids[instance_id] = card_id
	should_sync = true

func remove_card(instance_id: int) -> void:
	card_ids.erase(instance_id)
	should_sync = true
