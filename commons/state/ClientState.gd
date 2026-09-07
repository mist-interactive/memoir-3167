extends Node
class_name ClientState
var authenticated: bool = false:
	set(val):
		should_sync = true
		authenticated = val
var failed_auth: bool = false:
	set(val):
		failed_auth = val
		should_sync = true

var display_name: String:
	set(val):
		display_name = val
		should_sync = true

var uuid: int:
	set(val):
		uuid = val
		should_sync = true

var connected_to_game: bool = false:
	set(val):
		connected_to_game = val
		should_sync = true

var peer_id: int
var should_sync: bool = false

func _init(peer_id: int) -> void:
	name = "clientState"
	self.peer_id = peer_id
	Network.Client.sync_requested.connect(_on_sync_requested)

func get_snapshot() -> Dictionary:
	return {
		"authenticated": authenticated,
		"failed_auth": failed_auth,
		"connected_to_game": connected_to_game,
		"uuid": uuid,
		"display_name": display_name,
	}

func sync() -> void:
	if !should_sync:
		return

	should_sync = false
	Network.Client.sync.rpc_id(peer_id, get_snapshot())

func _on_sync_requested(snapshot: Dictionary) -> void:
	authenticated = snapshot.authenticated
	failed_auth = snapshot.failed_auth
	connected_to_game = snapshot.connected_to_game
	uuid = snapshot.uuid
	display_name = snapshot.display_name
