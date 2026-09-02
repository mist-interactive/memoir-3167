class_name ClientHandState
extends HandState

signal hand_drawn
signal card_drawn
signal card_played(instance_id: int, card_id: String)
signal enemy_hand_drawn
signal enemy_card_drawn
signal enemy_card_played(instance_id: int, card_id: String)

@onready var match_state: MatchState = $"../matchState"

var event_queue: Array[Event]

func _ready() -> void:
	name = "HandState"
	Network.Hand.sync_requested.connect(_on_sync_requested)

func initialize(snapshot: Dictionary) -> void:
	_on_sync_requested(snapshot, false)
	flush_event_queue()

func _on_sync_requested(snapshot: Dictionary, flush_queue: bool = true):	
	if card_ids.size() > snapshot.card_ids.size() + 1:
		event_queue.append(Event.new(card_drawn))
	elif card_ids.size() == 0 && snapshot.card_ids.size() != 0:
		event_queue.append(Event.new(hand_drawn))
	
	if opponent_hand_size == snapshot.opponent_hand_size - 1:
		event_queue.append(Event.new(enemy_card_drawn))
	elif opponent_hand_size == 0 && snapshot.opponent_hand_size != 0:
		event_queue.append(Event.new(enemy_hand_drawn))
	
	var new_discard_pile: Array[CardInstance]
	for packed in snapshot.discard_pile:
		new_discard_pile.append(CardInstance.from_dict(packed))
	
	if discard_pile.size() != new_discard_pile.size():
		var card: CardInstance = new_discard_pile.back();
		var args: Array = [card.instance_id, card.card_id]
		var enemyPlayed: bool = card.owner_side != match_state.mySide
		var event: Event = Event.new(enemy_card_played if enemyPlayed else card_played, args)
		event_queue.append(event)
		
	card_ids = snapshot.card_ids
	discard_pile = new_discard_pile
	opponent_hand_size = snapshot.opponent_hand_size
	if flush_queue:
		flush_event_queue()

func flush_event_queue() -> void:
	for event: Event in event_queue:
			event.emit()
	event_queue.clear()
