extends Node
class_name Client
var authenticated: bool = false:
	set(val):
		should_sync = true
		authenticated = val
var display_name: String
var uuid: int
var peer_id: int #multiplayer id
var jwt_token: String
var should_sync: bool = false

func _init(peer_id: int) -> void:
	name = "clientState"
	self.peer_id = peer_id
	Network.Client.sync_requested.connect(_on_sync)

func get_snapshot() -> Dictionary:
	return {
		"authenticated": authenticated,
		"uuid": uuid,
		"display_name": display_name
	}

func sync() -> void:
	if !should_sync:
		return

	should_sync = false
	Network.Client.sync.rpc_id(peer_id, get_snapshot())

func _on_sync(snapshot: Dictionary) -> void:
	authenticated = snapshot.authenticated
	uuid = snapshot.uuid
	display_name = snapshot.display_name
