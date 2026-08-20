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
	Network.Match.connect_match.rpc()

signal init_match_requested(snapshot: Dictionary)
@rpc("authority","call_remote")
func init(snapshot: Dictionary) -> void:
	print("creating game")
	if multiplayer.is_server():
		return
	init_match_requested.emit(snapshot)

signal sync_requested(peer_id: int, snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	print("server wants to sync")
	sync_requested.emit(snapshot)

# client actions
signal update_client_match_change_requested(peer_id: int, state: MatchState.STATE)
@rpc("any_peer", "call_remote")
func update_client_match_state(state: MatchState.STATE):
	if !multiplayer.is_server():
		return
	update_client_match_change_requested.emit(multiplayer.get_remote_sender_id(), state)
