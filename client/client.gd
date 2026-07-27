extends Node
@export var loader: Loader
@export var menu: Node2D
@export var client: ClientState
var peer: WebSocketMultiplayerPeer
var url: String = "ws://localhost:80/ws/"
var connected: bool = false

func _ready() -> void:
	await loader.stage("Initializing connection...", initialize_connection) \
	.stage("Waiting to establish connection...", func(): await loader.wait_untill(func(): return connected == true)) \
	.stage("Initializing client...", func(): client = ClientState.new(multiplayer.get_unique_id())) \
	.stage("Authenticating client...", func():
		Network.Client.auth_check.rpc_id(1, "fsdfsdf")
		await loader.wait_untill(func(): return client.authenticated)
	) \
	.run()
	menu.show()

func _process(delta: float) -> void:
	pass

func _on_connected_to_server() -> void:
	print("Connected to server")

func _on_connection_failed() -> void:
	print("Failed to connect")
	
func _on_server_disconnected() -> void:
	print("Server disconnected")

func initialize_connection() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(url)
	if err != OK:
		return
	multiplayer.multiplayer_peer = peer
	connected = true
