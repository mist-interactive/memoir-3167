extends Node
class_name MatchNetwork

signal connect_match_requested
@rpc("any_peer","call_remote")
func connect_match() -> void:
	if !multiplayer.is_server():
		return
	print("connect to match")
	connect_match_requested.emit(multiplayer.get_remote_sender_id())
	
@rpc("authority","call_remote")
func match_created() -> void:
	if multiplayer.is_server():
		return
	print("here")
	Network.Match.connect_match.rpc()

signal init_match_requested
@rpc("authority","call_remote")
func init(matchId: int, mapName: String, player_ids: Array[int]) -> void:
	print("creating game")
	if multiplayer.is_server():
		return
	var battleField: Battlefield = Battlefield.new(mapName)
	var matchState: MatchState = MatchState.new(matchId, player_ids)
	init_match_requested.emit(battleField, matchState)
