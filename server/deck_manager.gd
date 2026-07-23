extends Node
class_name DeckManager

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []

var _next_instance_id: int = 1000 
var initial_hand_size: int = 6

# Maps peer_id to an Array of Dictionaries: Array[Dictionary]
# Each dict inside the hand array holds: {"instance_id": int, "card_id": String}
var player_hands: Dictionary = {} 

func _init(peer_id1: int, peer_id2: int) -> void:
	initialize_match_deck()

func deal_initial_hand(peer_id: int) -> void:
	player_hands[peer_id] = []
	
	for i in range(initial_hand_size):
		draw_card(peer_id)
		
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

func draw_card(peer_id: int) -> void:
	if draw_pile.is_empty():
		shuffle_deck()
		if draw_pile.is_empty(): return

	var drawn_card_id: String = draw_pile.pop_back()
	var assigned_id: int = _next_instance_id
	_next_instance_id += 1

	var card_instance = {
		"instance_id": assigned_id,
		"card_id": drawn_card_id
	}
	
	player_hands[peer_id].append(card_instance)
	
	Network.Card.receive_card_from_server.rpc_id(peer_id, assigned_id, drawn_card_id)

func shuffle_deck() -> void:
	if draw_pile.is_empty() and not discard_pile.is_empty():
		draw_pile.assign(discard_pile)
		discard_pile.clear()
	
	draw_pile.shuffle()

func start_deck_distribution(peer_a: int, peer_b: int) -> void:
	initialize_match_deck()
	deal_initial_hand(peer_a)
	deal_initial_hand(peer_b)
	print("DeckManager: Deck initialized and initial hands distributed to peers %d and %d." % [peer_a, peer_b])

func authenticate_and_use_card(peer_id: int, target_instance_id: String) -> bool:
	# ... Phase/Turn verification checks go here ...
	
	if not player_hands.has(peer_id): return false
	
	var hand: Array = player_hands[peer_id]
	var found_index: int = -1
	
	for i in range(hand.size()):
		if hand[i]["instance_id"] == target_instance_id:
			found_index = i
			break
			
	if found_index == -1:
		return false
		
	var used_card_data = hand[found_index]
	hand.remove_at(found_index)
	discard_pile.append(used_card_data["card_id"])
	
	return true
