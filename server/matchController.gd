extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager
var unit_manager: ServerUnitManager

var connected: Dictionary[int, bool]
var player_status: Dictionary[int, MatchState.STATE]
var UNIT_SCENE = preload("res://client/units/Unit.tscn")

func _init(matchState: MatchState, battlefield: BattlefieldState, deckManager: DeckManager) -> void:
	self.matchState = matchState
	self.battlefield = battlefield
	self.deckManager = deckManager

func _physics_process(delta: float) -> void:
	matchState.sync()

func clients_are_ready():
	if player_status.size() != 2:
		return false
	var player_id1 = matchState.player_ids[0]
	var player_id2 = matchState.player_ids[1]
	return player_status[player_id1] == MatchState.STATE.READY && player_status[player_id2] == MatchState.STATE.READY

func ready_to_initialize_board():
	if player_status.size() != 2:
		return false
	var player_id1 = matchState.player_ids[0]
	var player_id2 = matchState.player_ids[1]
	return player_status[player_id1] == MatchState.STATE.INITIALIZE_BOARD && player_status[player_id2] == MatchState.STATE.INITIALIZE_BOARD

# signal handlers
func handle_connect(player_id: int) -> void:
	self.connected[player_id] = true
	player_status[player_id] = MatchState.STATE.INITIALIZING
	Network.Match.init.rpc_id(player_id, matchState.matchId, battlefield.mapName, matchState.player_ids)

func handle_disconnect(player_id: int) -> void:
	self.connected[player_id] = false

func handle_client_state_change(player_id: int, state: MatchState.STATE) -> void:
	player_status[player_id] = state
	if matchState.state == MatchState.STATE.INITIALIZING && clients_are_ready():
		matchState.state = MatchState.STATE.INITIALIZE_BOARD
		deckManager.draw_hand(matchState.player_ids[0]) # shoud move to initialize_board stage
		deckManager.draw_hand(matchState.player_ids[1])
		deckManager.initialize_opponents_hands()

	if matchState.state == MatchState.STATE.INITIALIZE_BOARD && ready_to_initialize_board():
		matchState.state = MatchState.STATE.IN_PROGRESS
		unit_manager.spawn_units(matchState.player_ids[0], matchState.player_ids[1])
		matchState.phase = MatchState.TURN_PHASE.PLAY_CARD

func isPhase(phase: MatchState.TURN_PHASE) -> bool:
	return matchState.phase == phase
	
func isPlayerTurn(peer_id: int) -> bool:
	return matchState.player_ids[matchState.player_turn_index] == peer_id;

func isInProgress() ->bool:
	return matchState.state == MatchState.STATE.IN_PROGRESS
	
# Antti
func spawn_unit_on_server(owner_id: int, unit_type: String, start_coord: Vector2i) -> void:
	if not multiplayer.is_server():
		return
	#var unique_id: int = unit_manager.generate_server_unit_id()
	#var new_unit_data = UnitData.new(owner_id, unit_type, unique_id, start_coord)
	#unit_manager.add_unit(new_unit_data, start_coord)
	#for peer in matchState.player_ids:
		#sync_spawn_unit.rpc_id(peer, owner_id, unit_type, unique_id, start_coord)

@rpc("authority", "call_remote", "reliable")
func sync_spawn_unit(owner_id: int, unit_type: String, unique_id: int, coord: Vector2i) -> void:
	var new_unit_node = UNIT_SCENE.instantiate()
	new_unit_node.name = str(unique_id)
	new_unit_node.uuid = str(unique_id)
	new_unit_node.type = unit_type
	new_unit_node.hex_coord = coord
	new_unit_node.owner_id = owner_id
	unit_manager.active_container.add_child(new_unit_node)
	unit_manager.add_unit(new_unit_node, coord)

func process_hex_click(peer_id:int, hex: Vector2i) -> void:
	spawn_unit_on_server(peer_id, "test", hex)
	for player in matchState.player_ids:
		Network.Match.receive_hex_broadcast.rpc_id(player, peer_id, hex)
