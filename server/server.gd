extends Node
var peer: WebSocketMultiplayerPeer
var port: int = 6669
var clients: Dictionary[int, Client]
var sessions: Dictionary[int, int] # uuid -> peer_id

func _ready() -> void:
	name = "SERVER"

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Network.Client.auth_check_requested.connect(_on_auth_check)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Server started")

func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: Client = clients[peer_id]
		client.sync()

func _on_peer_connected(id: int) -> void:
	print("A new client has connected id: ", id)
	clients[id] = Client.new(id)

func _on_peer_disconnected(id: int) -> void:
	print("Client has disconnected: ", id)
	clients.erase(id)

func _on_auth_check(peer_id: int, jtw_token: String) -> void:
	print("Authenticating client %d..." % peer_id)
	var client: Client = clients[peer_id]
	client.authenticated = true
