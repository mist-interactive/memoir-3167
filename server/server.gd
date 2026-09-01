extends Node
class_name Server
var peer: WebSocketMultiplayerPeer
var port: int = 6669
var clients: Dictionary[int, ClientState]
var sessions: Dictionary[int, int] # uuid -> peer_id
var logger: LogService
@export var match_manager: MatchManager

func _ready() -> void:
	name = "SERVER"
	logger = LogService.new({"service": "server"})
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Network.Client.auth_check_requested.connect(_on_auth_check_requested)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	logger.info("server has started")

func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: ClientState = clients[peer_id]
		client.sync()

func _on_peer_connected(id: int) -> void:
	logger.info("A new client has connected", {"uuid": id})
	clients[id] = ClientState.new(id)

func _on_peer_disconnected(id: int) -> void:
	logger.info("Clien has disconnected", {"uuid": id})
	match_manager.client_disconnected(id)
	clients.erase(id)

func _on_auth_check_requested(peer_id: int, jwt_token: String) -> void:
	logger.info("Authenticating client", {"peer_id": peer_id, "jtw_token": jwt_token})
	var client: ClientState = clients[peer_id]
	client.authenticated = true
