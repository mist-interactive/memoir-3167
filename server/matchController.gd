extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager
var unit_manager: ServerUnitManager
var connected: Dictionary[enums.Side, bool]
var player_status: Dictionary[enums.Side, MatchState.STATE]
var UNIT_SCENE = preload("res://client/units/Unit.tscn")
var sides_peer_ids: Dictionary[enums.Side, int]

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

func clients_are_ready():
	if player_status.size() != 2:
		return false
	for status in player_status.values():
		if status != matchState.STATE.READY:
			return false
	return true

func ready_to_initialize_board():
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

func isInProgress() ->bool:
	return matchState.state == MatchState.STATE.IN_PROGRESS

func process_hex_click(peer_id:int, hex: Vector2i) -> void:
	for side in sides_peer_ids:
		Network.Match.receive_hex_broadcast.rpc_id(sides_peer_ids[side], get_side(peer_id), hex)
