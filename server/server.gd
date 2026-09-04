extends Node
class_name Server

var jwt_verifier: JwtVerifier

var peer: WebSocketMultiplayerPeer
var port: int = 6669
var clients: Dictionary[int, ClientState]
var sessions: Dictionary[int, int] # uuid -> peer_id
var logger: LogService
@export var match_manager: MatchManager

signal player_disconnected(peer_id: int)

func _ready() -> void:
	name = "SERVER"
	logger = LogService.new({"service": "server"})
	logger.info("=== SERVER STARTING ===")
	logger.info("OS feature editor: %s" % OS.has_feature("editor"))
	logger.info("OS feature web: %s" % OS.has_feature("web"))

	jwt_verifier = JwtVerifier.new(logger)

	if not jwt_verifier.is_ready:
		get_tree().quit(1)
		return
	if not OS.has_feature("editor"):
		logger.info("Loading JWT public key...")
		if not jwt_verifier.load_public_key():
			get_tree().quit(1)
			return
	else:
		logger.info("Editor mode: JWT public key loading skipped")

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Network.Client.auth_check_requested.connect(_on_auth_check_requested)
	peer = WebSocketMultiplayerPeer.new()
	var error := peer.create_server(port)
	logger.info("WebSocket server create result: %s" % error)
	logger.info("Listening on port: %d" % port)
	multiplayer.multiplayer_peer = peer
	logger.info("=== SERVER READY ===")
	logger.info("server has started")

func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: ClientState = clients[peer_id]
		client.sync()

func _on_peer_connected(peer_id: int) -> void:
	logger.info("=== CLIENT CONNECTED ===")
	logger.info("A new client has connected", {"uuid": peer_id})
	clients[peer_id] = ClientState.new(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	logger.info("=== CLIENT DISCONNECTED ===")
	logger.info("Client has disconnected", {"peer_id": peer_id})
	player_disconnected.emit(peer_id)
	clients.erase(peer_id)

func _on_auth_check_requested(peer_id: int, jwt_token: String) -> void:
	logger.info("=== AUTHENTICATION REQUEST ===")
	logger.info("Authenticating client %d..." % peer_id)
	var client: ClientState = clients.get(peer_id)
	if client == null:
		logger.info("Authentication failed: client %d not found" % peer_id)
		return

	if OS.has_feature("editor"):
		client.authenticated = true
		logger.info("Client %d authenticated (local)" % peer_id)
		return

	if jwt_verifier.verify(jwt_token):
		client.authenticated = true
		logger.info("Client %d authenticated" % peer_id)
	else:
		client.authenticated = false
		logger.info("Client %d authentication failed" % peer_id)
