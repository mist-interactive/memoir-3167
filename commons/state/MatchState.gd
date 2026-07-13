extends Node
class_name MatchState
var matchId: int
var player_ids: Array[int]
var scores: Dictionary[int, int]	
var state: STATE = STATE.INITIALIZING
enum STATE {INITIALIZING, READY, IN_PROGRESS, PAUSED, ENDED}

func _init(matchId: int, player_ids: Array[int]) -> void:
	name = "matchState"
	self.matchId = matchId
	self.player_ids = player_ids
	self.scores[player_ids[0]] = 0
	self.scores[player_ids[0]] = 0
	Network.Match.match_state_change_requested.connect(_on_state_change)
	

# signal handlers
func _on_state_change(state: MatchState.STATE):
	print("Upding client state")
	self.state = state
