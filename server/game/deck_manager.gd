extends Node
class_name DeckManager

var draw_pile: Array[String] = []
var discard_pile: Array[CardInstance] = []
var player_hands: Dictionary[int, HandState] = {}
var _next_instance_id: int = 1000 
var logger: LogService
@onready var match_controller: matchController = $".."
@onready var initial_hand_size: int = match_controller.config.match.hand_size

func _ready() -> void:
	logger = match_controller.logger.with_context({
		"component": "deckManager"
	})

func _init() -> void:
	name = "DeckManager"
	player_hands[enums.Side.GREEN] = HandState.new()
	player_hands[enums.Side.RED] = HandState.new()
	initialize_match_deck()

func _sync_hands() -> void:
	for side in [enums.Side.RED, enums.Side.GREEN]:
		var hand: HandState = player_hands[side]
		if not hand.should_sync:
			continue
		MessageBroker.send(match_controller.get_player_session(side),
			Network.Hand.sync.rpc_id,
			[hand.get_snapshot()]
		)
		hand.should_sync = false
		logger.info("synced new hand state")

func initialize_match_deck() -> void:
	draw_pile.clear()
	discard_pile.clear()
	for card_id in CardDatabase.card_registry.keys():
		var card_data = CardDatabase.get_card(card_id)
		
		if not card_data is CommandCard:
			continue
		
		var command_card := card_data as CommandCard
		
		for i in range(command_card.deck_quantity):
			draw_pile.append(card_id)
		draw_pile.shuffle()

func draw_card_from_pile() -> Dictionary:
	if draw_pile.is_empty():
		_refill_draw_pile()

	if draw_pile.is_empty():
		return {}

	var card_id: String = draw_pile.pop_back()

	var card_instance := {
		"instance_id": _next_instance_id,
		"card_id": card_id
	}

	_next_instance_id += 1
	return card_instance


func _refill_draw_pile() -> void:
	if discard_pile.is_empty():
		return

	for card_instance: CardInstance in discard_pile:
		draw_pile.append(card_instance.card_id)

	discard_pile.clear()
	draw_pile.shuffle()

	logger.info("Refilled draw pile", {
		"cards": draw_pile.size()
	})

func draw_card(side: enums.Side, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	var card_instance: Dictionary = draw_card_from_pile()
	if card_instance.is_empty():
		return false

	player_hands[side].add_card(
		card_instance.instance_id,
		card_instance.card_id
	)

	var other_side := get_other_side(side)

	# Update both players' knowledge of the hands
	player_hands[side].opponent_cards = get_opponent_cards(side)
	player_hands[other_side].opponent_cards = get_opponent_cards(other_side)

	var player_logger := logger.with_context({
		"peer_id": sides_peer_ids[side],
		"side": side
	})

	player_logger.info("Draw a card", card_instance)
	return true

func play_card(side: enums.Side, instance_id: int, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	var player_logger := logger.with_context({
		"peer_id": sides_peer_ids[side],
		"side": side
	})
	if !hasCardInHand(side, instance_id):
		return false
	var other_side: enums.Side = get_other_side(side)
	var card_id: String = player_hands[side].card_ids[instance_id]
	discard_pile.append(CardInstance.new(instance_id, card_id, side))
	player_hands[side].discard_pile = discard_pile
	player_hands[other_side].discard_pile = discard_pile
	player_hands[side].remove_card(instance_id)
	player_hands[other_side].opponent_cards = player_hands[side].card_ids.keys()
	player_logger.info("Played card", {"instance_id":instance_id, "card_id": card_id})
	return true

func draw_hand(side: enums.Side, player_session: PlayerSession) -> void:
	var player_logger := logger.with_context({
		"peer_id": player_session.peer_id,
		"side": side
	})
	if !player_hands[side].is_hand_drawn:
		var cards: Dictionary[int, String]
		for i in range(initial_hand_size):
			var card: Dictionary = draw_card_from_pile()
			if card.is_empty():
				break
			cards[card.instance_id] = card.card_id
		player_hands[side].is_hand_drawn = true
		player_hands[get_other_side(side)].opponent_cards = cards.keys()
		player_hands[side].opponent_cards = get_opponent_cards(side)
		player_hands[side].card_ids = cards
		logger.info("===> drawing player hand %d" % side)
	else:
		player_hands[side].should_sync = true
		player_hands[get_other_side(side)].should_sync = true
	player_logger.info("Draw hand", {"cards": player_hands[side].card_ids.size()})

func get_other_side(side: enums.Side) -> enums.Side:
	var other_side: enums.Side = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN
	return other_side

func get_opponent_cards(side: enums.Side) -> Array[int]:
	var other_side: enums.Side = get_other_side(side)
	return player_hands[other_side].card_ids.keys()

# helper functions
func hasCardInHand(side: enums.Side, instance_id: int) -> bool:
	return player_hands[side].card_ids.has(instance_id)

func get_card() -> CommandCard:
	if discard_pile.is_empty():
		return null
	var card: CommandCard = CardDatabase.get_card(discard_pile.back().card_id)
	return card

func card_was_played(side: enums.Side):
	return player_hands[side].card_ids.size() < initial_hand_size
