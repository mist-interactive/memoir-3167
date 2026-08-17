extends Node
class_name Server
var peer: WebSocketMultiplayerPeer
var port: int = 6669
var clients: Dictionary[int, ClientState]
var sessions: Dictionary[int, int] # uuid -> peer_id

func _ready() -> void:
	name = "SERVER"

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Network.Client.auth_check_requested.connect(_on_auth_check_requested)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Server started")

func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: ClientState = clients[peer_id]
		client.sync()

func _on_peer_connected(id: int) -> void:
	print("A new client has connected id: ", id)
	clients[id] = ClientState.new(id)

func _on_peer_disconnected(id: int) -> void:
	print("Client has disconnected: ", id)
	clients.erase(id)

func _on_auth_check_requested(peer_id: int, jwt_token: String) -> void:
	print("Authenticating client %d..." % peer_id)
	var client: ClientState = clients[peer_id]
	client.authenticated = true
