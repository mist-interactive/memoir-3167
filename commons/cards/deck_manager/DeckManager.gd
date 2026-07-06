class_name DeckManager
extends RefCounted

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var player_hands: Dictionary = {}

# Initialize the deck with card IDs based on your game design
func initialize_deck(starting_cards: Array[String]) -> void:
	draw_pile = starting_cards.duplicate()
	shuffle_deck()

func shuffle_deck() -> void:
	# If the draw pile is empty, shuffle the discard pile back into it
	if draw_pile.is_empty() and not discard_pile.is_empty():
		draw_pile = discard_pile.duplicate()
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
		player_hands[peer_id] = []
		
	player_hands[peer_id].append(drawn_card_id)
	return drawn_card_id
