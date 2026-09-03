extends Node
class_name MatchNetwork

signal connect_match_requested(peer_id: int, uuid: int, match_id: int)
@rpc("any_peer","call_remote")
func connect_match(uuid: int, match_id: int) -> void:
	if !multiplayer.is_server():
		return
	connect_match_requested.emit(multiplayer.get_remote_sender_id(), uuid, match_id)

signal client_ready_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func client_ready() -> void:
	client_ready_requested.emit(multiplayer.get_remote_sender_id())

signal client_game_ready_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func client_game_ready() -> void:
	client_game_ready_requested.emit(multiplayer.get_remote_sender_id())

@rpc("authority","call_remote")
func match_created() -> void:
	if multiplayer.is_server():
		return
	Network.Match.connect_match.rpc()

signal start_game_requested
@rpc("authority", "call_remote")
func start_game() -> void:
	start_game_requested.emit()

signal init_match_requested(snapshot: Dictionary)
@rpc("authority","call_remote")
func init(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	init_match_requested.emit(snapshot)

signal sync_requested(peer_id: int, snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_requested.emit(snapshot)
