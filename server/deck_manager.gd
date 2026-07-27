class_name DeckManager
extends Node

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var player_hands: Dictionary[int, HandState]

@onready var card_db: CardDatabase = CardDatabase.instance

func _init(peer_id1: int, peer_id2: int) -> void: # peer_id should be unique
	name = "deckmanager"
	player_hands[peer_id1] = HandState.new()
	player_hands[peer_id2] = HandState.new()
	initialize_deck()

func _physics_process(delta: float) -> void:
	for peer_id in player_hands.keys():
		var hand: HandState = player_hands[peer_id]
		if not hand.should_sync:
			continue
		Network.Hand.sync.rpc_id(peer_id, hand.get_snapshot())

func initialize_deck() -> void:
	var raw_keys: Array = CardDatabase.instance.card_registry.keys()
	var typed_starting_cards: Array[String] = []
	typed_starting_cards.assign(raw_keys)
	draw_pile.clear()
	draw_pile.assign(typed_starting_cards)
	shuffle_deck()

func shuffle_deck() -> void:
	if draw_pile.is_empty() and not discard_pile.is_empty():
		draw_pile.assign(discard_pile)
		discard_pile.clear()
		
	draw_pile.shuffle()

# Draws a card for a specific network peer
func draw_card(peer_id: int) -> String:
	if draw_pile.is_empty():
		shuffle_deck()
		if draw_pile.is_empty():
			return "" # No cards left anywhere
			
	var drawn_card_id: String = draw_pile.pop_back()
	
	if not player_hands.has(peer_id):
		return "" # could not map peer_id to hand
		
	player_hands[peer_id].add_card(drawn_card_id)
	return drawn_card_id

func draw_hand(peer_id: int) -> void:
	var hand: HandState = player_hands[peer_id]
	for i in range(0, 1, 1):
		var drawn_card_id: String = draw_pile.pop_back()
		hand.add_card(drawn_card_id)
