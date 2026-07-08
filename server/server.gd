extends Node
var peer: WebSocketMultiplayerPeer
var port: int = 6669
var peers: Array[int]

func _ready() -> void:
	name = "SERVER"

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Server started")
	

func _on_peer_connected(id: int) -> void:
	print("A new client has connected id: ", id)
	peers.append(id)

func _on_peer_disconnected(id: int) -> void:
	print("Client has disconnected: ", id)
	peers.erase(id)
