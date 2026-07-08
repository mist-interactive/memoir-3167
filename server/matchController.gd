extends Node
class_name  matchController
var matchState: MatchState
var battlefield: Battlefield

var connected: Dictionary[int, bool]

func _init(matchState: MatchState, battlefield: Battlefield) -> void:
	self.matchState = matchState
	self.battlefield = battlefield

func handle_connect(player_id: int) -> void:
	self.connected[player_id] = true
	Network.Match.init.rpc_id(player_id, matchState.matchId, battlefield.mapName, matchState.player_ids)

func handle_disconnect(player_id: int) -> void:
	self.connected[player_id] = false
