extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager
var unit_manager: ServerUnitManager
var connected: Dictionary[enums.Side, bool]
var player_status: Dictionary[enums.Side, MatchState.STATE]
var sides_peer_ids: Dictionary[enums.Side, int]
var logger: LogService

func _init(matchId: int, peer_id1: int, peer_id2: int) -> void:
	name = "Match_" + str(matchId)
	matchState = MatchState.new()
	matchState._initialize(matchId)
	battlefield = BattlefieldState.new("map.json")
	deckManager = DeckManager.new()
	unit_manager = ServerUnitManager.new(battlefield)
	sides_peer_ids = {enums.Side.GREEN: peer_id1, enums.Side.RED: peer_id2}
	add_child(matchState)
	add_child(battlefield)
	add_child(deckManager)
	add_child(unit_manager)

func _physics_process(delta: float) -> void:
	matchState.sync(sides_peer_ids)
	deckManager._sync_hands(sides_peer_ids)
	unit_manager._sync_units(sides_peer_ids)

func get_side(peer_id: int) -> enums.Side:
	for side in sides_peer_ids:
		if peer_id == sides_peer_ids[side]:
			return side
	return enums.Side.NONE

func clients_are_ready() -> bool:
	if player_status.size() != 2:
		return false
	for status in player_status.values():
		if status != matchState.STATE.READY:
			return false
	return true

func ready_to_initialize_board() -> bool:
	if player_status.size() != 2:
		return false
	for status in player_status.values():
		if status != matchState.STATE.INITIALIZE_BOARD:
			return false
	return true

# signal handlers
func handle_connect(peer_id: int) -> void:
	self.connected[get_side(peer_id)] = true
	player_status[get_side(peer_id)] = MatchState.STATE.INITIALIZING
	#Network.Match.init.rpc_id(peer_id, matchState.matchId, battlefield.mapName)

func handle_disconnect(peer_id: int) -> void:
	self.connected[get_side(peer_id)] = false

func peer_reconnected(peer_id: int, old_peer_id: int) -> void:
	var side: enums.Side = get_side(old_peer_id)
	sides_peer_ids[side] = peer_id
	connected[side] = false

func handle_client_state_change(peer_id: int, state: MatchState.STATE) -> void:
	player_status[get_side(peer_id)] = state
	if matchState.state == MatchState.STATE.INITIALIZING && clients_are_ready():
		matchState.state = MatchState.STATE.INITIALIZE_BOARD

	if matchState.state == MatchState.STATE.INITIALIZE_BOARD && ready_to_initialize_board():
		matchState.state = MatchState.STATE.IN_PROGRESS
		unit_manager.spawn_units(sides_peer_ids)
		matchState.phase = enums.TurnPhase.PLAY_CARD

func isPhase(phase: enums.TurnPhase) -> bool:
	return matchState.phase == phase

func isPlayerTurn(peer_id: int) -> bool:
	var side: enums.Side = get_side(peer_id)
	return matchState.current_turn == side;

func validate_unit_selection(unit_id: int) -> bool:
	var card: CommandCard = deckManager.get_card()
	match matchState.phase:
		enums.TurnPhase.SELECT:
			return false if !unit_manager.can_card_target_unit(card, unit_id) else true
		enums.TurnPhase.MOVE:
			return false if !unit_manager.is_unit_selected(unit_id) || unit_manager.has_unit_moved(unit_id) else true
		enums.TurnPhase.ATTACK:
			return false if !unit_manager.is_unit_selected(unit_id) || unit_manager.has_unit_attacked(unit_id) else true
	return false

func isInProgress() ->bool:
	return matchState.state == MatchState.STATE.IN_PROGRESS

func go_next_phase(side: enums.Side) -> void:
	if isPhase(enums.TurnPhase.ATTACK) || (isPhase(enums.TurnPhase.SELECT) && unit_manager.selected_units_ids.is_empty()):
		matchState.phase = enums.TurnPhase.PLAY_CARD
		matchState.current_turn = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN
		unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
	elif isPhase(enums.TurnPhase.SELECT):
		matchState.phase = enums.TurnPhase.MOVE
		unit_manager.next_phase(enums.TurnPhase.MOVE)
	elif isPhase(enums.TurnPhase.MOVE):
		matchState.phase = enums.TurnPhase.ATTACK
		unit_manager.next_phase(enums.TurnPhase.ATTACK)

# Action handlers
func handle_continue_next_phase(side: enums.Side) -> void:
	go_next_phase(side)

func handle_draw_hand(side: enums.Side) -> void:
	deckManager.draw_hand(side, sides_peer_ids)
	for hand: HandState in deckManager.player_hands.values():
		if hand.card_ids.size() == 0:
			return
	matchState.phase = enums.TurnPhase.PLAY_CARD

func handle_play_card(side: enums.Side, instance_id: int) -> void:
	if deckManager.play_card(side, instance_id, sides_peer_ids):
		matchState.phase = enums.TurnPhase.SELECT

func handle_select_unit(side: enums.Side, unit_id: int) -> void:
	if !validate_unit_selection(unit_id):
		return
	unit_manager.select_unit(side, unit_id, deckManager.get_card())

func handle_move_unit(side: enums.Side, unit_id: int, destination: Vector2i) -> void:
	if unit_manager.move_unit_request(side, unit_id, destination, sides_peer_ids):
		if unit_manager.moved_units_ids.size() == unit_manager.selected_units_ids.size():
			matchState.phase = enums.TurnPhase.ATTACK
			unit_manager.next_phase(enums.TurnPhase.ATTACK)
	
func handle_attack_unit(side: enums.Side, unit_id: int, target_unit_id: int) -> void:
	if unit_manager.attack_unit(side, unit_id, target_unit_id, sides_peer_ids):
		if unit_manager.attacked_units_ids.size() == unit_manager.selected_units_ids.size():
			unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
			matchState.phase = enums.TurnPhase.PLAY_CARD
			matchState.current_turn = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN

func handle_draw_card(side: enums.Side) -> void:
	if deckManager.draw_card(side, sides_peer_ids):
		matchState.phase = enums.TurnPhase.PLAY_CARD
		unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
