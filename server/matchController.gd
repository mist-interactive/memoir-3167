extends Node
class_name  matchController
var matchState: MatchState
var battlefield: BattlefieldState

var connected: Dictionary[int, bool]
var player_status: Dictionary[int, MatchState.STATE]

func _init(matchState: MatchState, battlefield: BattlefieldState) -> void:
	self.matchState = matchState
	self.battlefield = battlefield

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
		matchState.state = MatchState.STATE.READY
