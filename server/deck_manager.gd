extends Node
class_name DeckManager

var draw_pile: Array[String] = []
var discard_pile: Array[CardInstance] = []
var player_hands: Dictionary[int, HandState]

var _next_instance_id: int = 1000 
var initial_hand_size: int = 6

func _init() -> void:
	name = "DeckManager"
	player_hands[enums.Side.GREEN] = HandState.new()
	player_hands[enums.Side.RED] = HandState.new()
	initialize_match_deck()

func _sync_hands(sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	for side in player_hands.keys():
		var peer_id: int = sides_peer_ids[side]
		var hand: HandState = player_hands[side]
		if not hand.should_sync:
			continue
		Network.Hand.sync.rpc_id(peer_id, hand.get_snapshot())
		hand.should_sync = false

func initialize_match_deck() -> void:
	draw_pile.clear()
	discard_pile.clear()
	
	for card_id in CardDatabase.card_registry.keys():
		var card_data: CommandCard = CardDatabase.get_card(card_id)
		if not card_data:
			continue
			
		for i in range(card_data.deck_quantity):
			draw_pile.append(card_id)
		
	shuffle_deck()
	print("Server Deck Manager: Deck initialized with %d total cards." % draw_pile.size())

func draw_card_from_pile() -> Dictionary:
	if draw_pile.is_empty():
		shuffle_deck()
		if draw_pile.is_empty(): return {}
	
	var card_instance = {
		"instance_id":  _next_instance_id,
		"card_id": draw_pile.pop_back()
	}
	_next_instance_id += 1
	return card_instance

func draw_card(side: enums.Side, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	var card_instance: Dictionary = draw_card_from_pile()
	if card_instance.is_empty():
		return false
	player_hands[side].add_card(card_instance.instance_id, card_instance.card_id)
	player_hands[side].opponent_hand_size = get_opponent_hand_size(side)
	return true

func shuffle_deck() -> void:
	if draw_pile.is_empty() and not discard_pile.is_empty():
		draw_pile.assign(discard_pile)
		discard_pile.clear()
	
	draw_pile.shuffle()

func play_card(side: enums.Side, instance_id: int, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	if !hasCardInHand(side, instance_id):
		return false
	var other_side: enums.Side = get_other_side(side)
	var card_id: String = player_hands[side].card_ids[instance_id]
	discard_pile.append(CardInstance.new(instance_id, card_id))
	player_hands[side].discard_pile = discard_pile
	player_hands[other_side].discard_pile = discard_pile
	player_hands[side].remove_card(instance_id)
	return true

func draw_hand(side: enums.Side, sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	var cards: Dictionary[int, String]
	for i in range(initial_hand_size):
		var card: Dictionary = draw_card_from_pile()
		if card.is_empty():
			break
		cards[card.instance_id] = card.card_id
	player_hands[get_other_side(side)].opponent_hand_size = cards.size()
	player_hands[side].card_ids = cards

func get_other_side(side: enums.Side) -> enums.Side:
	var other_side: enums.Side
	for other in player_hands.keys():
		if other != side:
			other_side = other
			break
	return other_side

func get_opponent_hand_size(side: enums.Side) -> int:
	var other_side: enums.Side = get_other_side(side)
	return player_hands[other_side].card_ids.size()

# helper functions
func hasCardInHand(side: enums.Side, instance_id: int) -> bool:
	return player_hands[side].card_ids.has(instance_id)
