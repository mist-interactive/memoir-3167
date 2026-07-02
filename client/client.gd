extends Node
var peer: WebSocketMultiplayerPeer
var url: String = "ws://localhost:6669"

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_client(url)
	multiplayer.multiplayer_peer = peer

func _process(delta: float) -> void:
	pass

func _on_connected_to_server() -> void:
	print("Connected to server")

func _on_connection_failed() -> void:
	print("Failed to connect")
	
func _on_server_disconnected() -> void:
	print("Server disconnected")
