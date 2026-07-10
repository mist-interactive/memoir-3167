class_name DeckManager
extends Node

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var player_hands: Dictionary = {}

@onready var card_db: CardDatabase = CardDatabase.instance

func _init(player1: int, player2: int) -> void:
	name = "deckmanager"
	var raw_keys: Array = CardDatabase.instance.card_registry.keys()
	var typed_starting_cards: Array[String] = []
	typed_starting_cards.assign(raw_keys)
	initialize_deck(typed_starting_cards)

func initialize_deck(starting_cards: Array[String]) -> void:
	draw_pile.clear()
	draw_pile.assign(starting_cards)
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
		player_hands[peer_id] = [] as Array[String]
		
	player_hands[peer_id].append(drawn_card_id)
	return drawn_card_id
