extends Node
class_name ClientNetwork

signal auth_check_requested(peer_id: int, jwt_token: String)
@rpc("any_peer", "call_remote")
func auth_check(jwt_token: String) -> void:
	if !multiplayer.is_server():
		return
	auth_check_requested.emit(multiplayer.get_remote_sender_id(), jwt_token)

signal sync_requested(snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	print("Client sync requested")
	sync_requested.emit(snapshot)
