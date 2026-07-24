extends Node
class_name MatchNetwork

signal server_hex_requested(peer_id: int, hex: Vector2i)
signal hex_broadcast(peer_id: int, hex: Vector2i)

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
	Network.Match.connect_match.rpc()

signal init_match_requested
@rpc("authority","call_remote")
func init(matchId: int, mapName: String, player_ids: Array[int]) -> void:
	print("creating game")
	if multiplayer.is_server():
		return
	var battleField: BattlefieldState = BattlefieldState.new(mapName)
	var matchState: MatchState = MatchState.new(matchId, player_ids)
	init_match_requested.emit(battleField, matchState)

@rpc("any_peer", "call_remote", "reliable")
func request_hex_selection(hex: Vector2i) -> void:
	if !multiplayer.is_server():
		return
	print("hex selection requested")
	var sender := multiplayer.get_remote_sender_id()
	server_hex_requested.emit(sender, hex)

@rpc("authority", "call_remote", "reliable")
func receive_hex_broadcast(peer_id: int, hex: Vector2i) -> void:
	hex_broadcast.emit(peer_id, hex)
