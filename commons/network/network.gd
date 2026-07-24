extends Node
@export var Match: MatchNetwork

signal join_queue_requested(peer_id: int)
signal server_hex_requested(peer_id:int, hex: Vector2i)

@rpc("any_peer","call_remote")
func join_queue() -> void:
	print("calling to server")
	join_queue_requested.emit(multiplayer.get_remote_sender_id())

# usva
signal hex_selected(peer_id: int, hex: Vector2i)
signal hex_broadcast(peer_id: int, hex: Vector2i)

@rpc("any_peer", "call_remote", "reliable")
func request_hex_selection(hex: Vector2i) -> void:
	# runs on server
	if !multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	server_hex_requested.emit(sender, hex)
#	hex_selected.emit(sender, hex)

	# fan out to everyone
#	sync_hex_selection.rpc(sender, hex)

@rpc("authority", "call_local", "reliable")
func sync_hex_selection(peer_id: int, hex: Vector2i) -> void:
	# runs on all peers
	hex_broadcast.emit(peer_id, hex)
