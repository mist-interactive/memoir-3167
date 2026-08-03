extends Node
class_name DeckManager

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var player_hands: Dictionary[int, HandState]

var _next_instance_id: int = 1000 
var initial_hand_size: int = 6

func _init(peer_id1: int, peer_id2: int) -> void: # peer_id should be unique
	name = "deckmanager"
	player_hands[peer_id1] = HandState.new()
	player_hands[peer_id2] = HandState.new()
	initialize_match_deck()

func _physics_process(delta: float) -> void:
	for peer_id in player_hands.keys():
		var hand: HandState = player_hands[peer_id]
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
			
		for i in range(card_data.quantity):
			draw_pile.append(card_id)
		
	shuffle_deck()
	print("Server Deck Manager: Deck initialized with %d total cards." % draw_pile.size())

func draw_card(peer_id: int) -> bool:
	if draw_pile.is_empty():
		shuffle_deck()
		if draw_pile.is_empty(): return false

	var drawn_card_id: String = draw_pile.pop_back()
	var assigned_id: int = _next_instance_id
	_next_instance_id += 1

	var card_instance = {
		"instance_id": assigned_id,
		"card_id": drawn_card_id
	}
	
	player_hands[peer_id].add_card(assigned_id, drawn_card_id)
	player_hands[peer_id].opponent_hand_size = get_opponent_hand_size(peer_id)
	
	Network.Card.receive_card_from_server.rpc_id(peer_id, assigned_id, drawn_card_id)
	return true

func shuffle_deck() -> void:
	if draw_pile.is_empty() and not discard_pile.is_empty():
		draw_pile.assign(discard_pile)
		discard_pile.clear()
	
	draw_pile.shuffle()

func play_card(peer_id: int, instance_id: int) -> bool:
	if !hasCardInHand(peer_id, instance_id):
		return false
	player_hands[peer_id].remove_card(instance_id)
	for peer in player_hands:
		Network.Actions.card_played.rpc_id(peer, peer_id, instance_id)
	Network.Actions.receive_enemy_hand_update.rpc_id(get_opponent_id(peer_id), player_hands[peer_id].card_ids.size())
	
	return true

func draw_hand(peer_id: int) -> void:
	if not player_hands.has(peer_id): return
	var hand: HandState = player_hands[peer_id]
	for i in range(initial_hand_size):
		draw_card(peer_id)
	Network.Actions.hand_drawn.rpc_id(peer_id)
	player_hands[peer_id].opponent_hand_size = get_opponent_hand_size(peer_id)

func get_opponent_hand_size(peer_id: int) -> int:
	for key in player_hands:
		if key != peer_id:
			return player_hands[key].card_ids.size()
	return -1

func initialize_opponents_hands() -> void:
	for key in player_hands:
		player_hands[key].opponent_hand_size = get_opponent_hand_size(key)

# helper functions
func hasCardInHand(peer_id: int, instance_id: int) -> bool:
	return player_hands[peer_id].card_ids.has(instance_id)
