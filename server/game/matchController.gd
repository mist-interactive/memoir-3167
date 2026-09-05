extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager
var unit_manager: ServerUnitManager
var player_game_ready: Dictionary[int, bool]
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
	check_win_condition()
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

# signal handlers
func handle_connect(uuid: int, peer_id: int) -> void:
	session_manager.register_new_session(uuid, peer_id)
	logger.info("Client(%d) joining game" % uuid)
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
	var peer_ids: Array[int]
	var uuids: Array[int] = session_manager.get_uuids()
	assert(uuids.size() == 2)
	if matchState.state == MatchState.STATE.INITIALIZING:
		sides_uuid = {enums.Side.GREEN: uuids[0], enums.Side.RED: uuids[1]}
	var snapshot: Dictionary = {
		"match_state": matchState.get_snapshot(get_side(peer_id)),
		"hand_state": deckManager.player_hands[get_side(peer_id)].get_snapshot(),
		"map_name": battlefield.mapName,
		"units": units
	}
	for session: PlayerSession in session_manager.get_sessions().values():
		if session.is_status_set(enums.ConnectionStatus.Connected) && !session.is_status_set(enums.ConnectionStatus.Ready):
			peer_ids.append(session.peer_id)
	Network.broadcast(Network.Match.init.rpc_id, peer_ids, [snapshot])
		
func handle_client_ready(uuid: int) -> void:
	logger.info("Client(%s) is ready" % uuid)
	session_manager.client_is_ready(uuid)
	if !session_manager.players_are_ready():
		return
	var peer_ids: Array[int] = []
	for session: PlayerSession in session_manager.get_sessions().values():
		if session.is_status_set(enums.ConnectionStatus.Ready) && !session.is_status_set(enums.ConnectionStatus.Playing):
			peer_ids.append(session.peer_id)
	Network.broadcast(Network.Match.start_game.rpc_id, peer_ids)

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

	for uuid_ in session_manager.get_uuids():
		session_manager.client_is_playing(uuid_)

func handle_disconnect(side: enums.Side) -> void:
	matchState.state = MatchState.STATE.PAUSED
	session_manager.client_disconnected(sides_uuid[side])

# Action handlers
func handle_continue_next_phase(side: enums.Side) -> void:
	go_next_phase(side)

func handle_play_card(side: enums.Side, instance_id: int) -> void:
	if deckManager.play_card(side, instance_id, get_sides_peer_ids()):
		go_next_phase(side)

func handle_select_unit(side: enums.Side, unit_id: int) -> void:
	if !unit_manager.validate_unit_selection(unit_id, deckManager.get_card()):
		return
	unit_manager.select_unit(side, unit_id, deckManager.get_card())

func handle_move_unit(side: enums.Side, unit_id: int, destination: Vector2i) -> void:
	if unit_manager.move_unit_request(side, unit_id, destination, get_sides_peer_ids()):
		if unit_manager.moved_units_ids.size() == unit_manager.selected_units_ids.size():
			go_next_phase(side)
	
func handle_attack_unit(side: enums.Side, unit_id: int, target_unit_id: int) -> void:
	if unit_manager.attack_unit(side, unit_id, target_unit_id, get_sides_peer_ids()):
		if unit_manager.attacked_units_ids.size() == unit_manager.selected_units_ids.size():
			go_next_phase(side)

func handle_draw_card(side: enums.Side) -> void:
	if deckManager.draw_card(side, get_sides_peer_ids()):
		go_next_phase(side)

# helpers
func isInProgress() ->bool:
	return matchState.state == MatchState.STATE.IN_PROGRESS

func isPhase(phase: enums.TurnPhase) -> bool:
	return matchState.is_phase(phase)

func isPlayerTurn(peer_id: int) -> bool:
	var side: enums.Side = get_side(peer_id)
	return matchState.current_turn == side;
	
func get_side(peer_id: int) -> enums.Side:
	return sides_uuid[match_manager.get_uuid(peer_id)]

func get_sides_peer_ids() -> Dictionary[enums.Side, int]:
	return session_manager.get_sides_peer_ids(sides_uuid) 
	
func check_win_condition() -> void:
	if matchState.winner != enums.Side.NONE:
		return
	match matchState.get_winner(2):
		enums.Side.GREEN:
			matchState.state = MatchState.STATE.ENDED
			matchState.winner = enums.Side.GREEN
		enums.Side.RED:
			matchState.state = MatchState.STATE.ENDED
			matchState.winner = enums.Side.RED
		enums.Side.NONE:
			pass

func go_next_phase(side: enums.Side) -> void:
	if matchState.is_phase(enums.TurnPhase.PLAY_CARD):
		unit_manager.next_phase(enums.TurnPhase.SELECT)
	elif matchState.is_phase(enums.TurnPhase.ATTACK) || (matchState.is_phase(enums.TurnPhase.SELECT) && unit_manager.selected_units_ids.is_empty()):
		matchState.current_turn = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN
		unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
	elif matchState.is_phase(enums.TurnPhase.SELECT):
		unit_manager.next_phase(enums.TurnPhase.MOVE)
	elif matchState.is_phase(enums.TurnPhase.MOVE):
		unit_manager.next_phase(enums.TurnPhase.ATTACK)
