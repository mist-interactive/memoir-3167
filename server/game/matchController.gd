extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager
var unit_manager: ServerUnitManager
var player_game_ready: Dictionary[int, bool]
var player_sessions: Dictionary[int, PlayerSession] # uuid-->PlayerSession
#var sides_peer_ids: Dictionary[enums.Side, int]
var sides_uuid: Dictionary[enums.Side, int]
var logger: LogService
@onready var match_manager: MatchManager = $"../MatchManager"
@onready var session_manager: SessionManager = $"./SessionManager"

func _ready() -> void:
	assert(match_manager != null)
	assert(session_manager != null)

func _init(matchId: int) -> void:
	name = "Match_" + str(matchId)
	matchState = MatchState.new()
	matchState._initialize(matchId)
	battlefield = BattlefieldState.new("map.json")
	deckManager = DeckManager.new()
	unit_manager = ServerUnitManager.new(battlefield)
	add_child(matchState)
	add_child(battlefield)
	add_child(deckManager)
	add_child(unit_manager)
	add_child(SessionManager.new())

func _physics_process(delta: float) -> void:
	var sides_peer_ids: Dictionary[enums.Side, int] = get_sides_peer_ids()
	matchState.sync(sides_peer_ids)
	deckManager._sync_hands(sides_peer_ids)
	unit_manager._sync_units(sides_peer_ids)
	match matchState.phase:
		enums.TurnPhase.DRAW_HAND:
			var hands_drawn: bool = deckManager.player_hands[enums.Side.GREEN].is_hand_drawn && deckManager.player_hands[enums.Side.RED].is_hand_drawn
			if hands_drawn:
				matchState.phase = enums.TurnPhase.PLAY_CARD
	match matchState.state:
		MatchState.STATE.PAUSED:
			pass
			if session_manager.players_are_connected():	
				matchState.state = MatchState.STATE.IN_PROGRESS
		MatchState.STATE.INITIALIZE_BOARD:
			logger.info("Initializing board")
			unit_manager.spawn_units(get_sides_peer_ids())
			for side in sides_uuid:
				deckManager.draw_hand(side, get_sides_peer_ids())
			matchState.state = MatchState.STATE.IN_PROGRESS

func get_side(peer_id: int) -> enums.Side:
	return sides_uuid[match_manager.get_uuid(peer_id)]

func get_sides_peer_ids() -> Dictionary[enums.Side, int]:
	return session_manager.get_sides_peer_ids(sides_uuid) 

# signal handlers
func handle_connect(uuid: int, peer_id: int) -> void:
	session_manager.register_new_session(uuid, peer_id)
	if !session_manager.players_are_connected():
		return
	var units: Array[Dictionary]
	for unit: UnitData in unit_manager.units_by_id.values():
		units.append({
			"owner_id": unit.owner_id,
			"uuid": unit.uuid,
			"type": unit.type,
			"coord": unit.hex_coord
		})
	var peer_ids: Array[int] = session_manager.get_peer_ids()
	var uuids: Array[int] = session_manager.get_uuids()
	assert(peer_ids.size() == 2 && uuids.size() == 2)
	logger.info("clients  connected", {"ids": peer_ids})
	if matchState.state == MatchState.STATE.INITIALIZING:
		sides_uuid = {enums.Side.GREEN: uuids[0], enums.Side.RED: uuids[1]}
	var snapshot: Dictionary = {
		"match_state": matchState.get_snapshot(get_side(peer_id)),
		"hand_state": deckManager.player_hands[get_side(peer_id)].get_snapshot(),
		"map_name": battlefield.mapName,
		"units": units
	}
	if matchState.state != MatchState.STATE.INITIALIZING:
		Network.Match.init.rpc_id(peer_id, snapshot)
	else:
		Network.broadcast(Network.Match.init.rpc_id, peer_ids, [snapshot])
		
func handle_client_ready(uuid: int) -> void:
	logger.info("Client(%s) is ready" % uuid)
	session_manager.client_is_ready(uuid)
	if !session_manager.players_are_ready():
		return
	Network.broadcast(Network.Match.start_game.rpc_id, session_manager.get_peer_ids())

func handle_client_game_ready(uuid: int) -> void:
	player_game_ready[uuid] = true
	if player_game_ready.size() != 2:
		return
	for ready in player_game_ready.values():
		if !ready:
			return
	if matchState.state == MatchState.STATE.INITIALIZING:
		matchState.state = MatchState.STATE.INITIALIZE_BOARD
	elif matchState.state == MatchState.STATE.PAUSED:
		matchState.state == MatchState.STATE.IN_PROGRESS

func handle_disconnect(side: enums.Side) -> void:
	matchState.state = MatchState.STATE.PAUSED
	session_manager.client_disconnected(sides_uuid[side])

func peer_reconnected(peer_id: int, old_peer_id: int) -> void:
	var side: enums.Side = get_side(old_peer_id)
	#sides_peer_ids[side] = peer_id

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
	logger.info("Draw hand")
	deckManager.draw_hand(side, get_sides_peer_ids())

func handle_play_card(side: enums.Side, instance_id: int) -> void:
	if deckManager.play_card(side, instance_id, get_sides_peer_ids()):
		matchState.phase = enums.TurnPhase.SELECT

func handle_select_unit(side: enums.Side, unit_id: int) -> void:
	if !validate_unit_selection(unit_id):
		return
	unit_manager.select_unit(side, unit_id, deckManager.get_card())

func handle_move_unit(side: enums.Side, unit_id: int, destination: Vector2i) -> void:
	if unit_manager.move_unit_request(side, unit_id, destination, get_sides_peer_ids()):
		if unit_manager.moved_units_ids.size() == unit_manager.selected_units_ids.size():
			matchState.phase = enums.TurnPhase.ATTACK
			unit_manager.next_phase(enums.TurnPhase.ATTACK)
	
func handle_attack_unit(side: enums.Side, unit_id: int, target_unit_id: int) -> void:
	if unit_manager.attack_unit(side, unit_id, target_unit_id, get_sides_peer_ids()):
		if unit_manager.attacked_units_ids.size() == unit_manager.selected_units_ids.size():
			unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
			matchState.phase = enums.TurnPhase.PLAY_CARD
			matchState.current_turn = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN

func handle_draw_card(side: enums.Side) -> void:
	
	if deckManager.draw_card(side, get_sides_peer_ids()):
		matchState.phase = enums.TurnPhase.PLAY_CARD
		unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
