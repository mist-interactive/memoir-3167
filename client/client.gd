extends Node
class_name WebClient
@export var loader: Loader
@export var menu: Node2D
@export var client: ClientState
var peer: WebSocketMultiplayerPeer
var url: String = "ws://localhost:6669"
static var connected: bool = false
static var reconnecting: bool = false
var reconnectAttempts: int = 0
const MAX_RECONNECT_ATTEMPS: int = 3

signal connection_status_change()
signal reconnection_attempt()

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
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
	connected = true
	reconnectAttempts = 0
	connection_status_change.emit()

func _on_connection_failed() -> void:
	print("Failed to connect ")
	if reconnectAttempts < MAX_RECONNECT_ATTEMPS:
		reconnect_to_server()
	else:
		connection_status_change.emit()

func _on_server_disconnected() -> void:
	print("server disconnected")
	connected = false
	reconnect_to_server()


func initialize_connection() -> void:
	if OS.has_feature("web"):
		var host = JavaScriptBridge.eval("window.location.hostname")
		url = "ws://" + host + ":8080/ws"
		print(url)

	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(url)
	if err != OK:
		return
	multiplayer.multiplayer_peer = peer

func reconnect_to_server():
	reconnection_attempt.emit()
	multiplayer.multiplayer_peer = null
	reconnectAttempts += 1
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(url)
	await get_tree().create_timer(2).timeout
	multiplayer.multiplayer_peer = peer
	connected = true

func get_cookie(cookie_name: String) -> String:
	if not OS.has_feature("web"):
		return ""
	# JavaScript to find a specific cookie by name
	var js_code = """
		(function() {
			var match = document.cookie.match(new RegExp('(^| )' + '%s' + '=([^;]+)'));
			return match ? match[2] : '';
		})();
	""" % cookie_name
	var result = JavaScriptBridge.eval(js_code)
	return str(result) if result else ""
	
