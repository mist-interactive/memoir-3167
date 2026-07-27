extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState
var deckManager: DeckManager

var connected: Dictionary[int, bool]
var player_status: Dictionary[int, MatchState.STATE]

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
		matchState.state = MatchState.STATE.IN_PROGRESS
		deckManager.draw_hand(matchState.player_ids[0])
		Network.Actions.hand_drawn.rpc_id(matchState.player_ids[0])
		deckManager.draw_hand(matchState.player_ids[1])
		Network.Actions.hand_drawn.rpc_id(matchState.player_ids[1])

func isPhase(phase: MatchState.TURN_PHASE) -> bool:
	return matchState.phase == phase
	
func isPlayerTurn(peer_id: int) -> bool:
	return matchState.player_ids[matchState.player_turn_index] == peer_id;

func isInProgress() ->bool:
	return matchState.state == MatchState.STATE.IN_PROGRESS
	
