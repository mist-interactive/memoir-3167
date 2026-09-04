extends Node
class_name WebClient
@export var loader: Loader
@export var client: ClientState
@export var game: Node
var peer: WebSocketMultiplayerPeer
var url: String = "ws://localhost:6669"
static var connected: bool = false
var failed:bool = false
static var reconnecting: bool = false
var players_connected: bool = false
var players_ready: bool = false
var initialized: bool = false
var reconnectAttempts: int = 0
const MAX_RECONNECT_ATTEMPS: int = 3
@onready var uuid = $uuid
var js_callback: JavaScriptObject

signal react_data_received(token: String, match_id: int)

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	var auth_data: Dictionary = await _get_authentication_data()
	uuid.text = str(auth_data["uuid"])
	if auth_data.is_empty():
		push_error("No authentication data was received.")
		return
	await loader.stage("Initializing connection...", initialize_connection) \
	.stage("Authenticating client...", func():
		client = ClientState.new(multiplayer.get_unique_id())
		Network.Client.auth_check.rpc_id(1, auth_data.get("token"))
		await loader.wait_untill(func(): return client.authenticated)
		if !client.authenticated:
			return taskResult.new(false, "Authentication failed")
		return taskResult.new()
	) \
	.stage("Joining game...", func():
		Network.Match.connect_match.rpc_id(1, auth_data.get("uuid"), auth_data.get("match_id"))
		await loader.wait_untill(func(): return client.connected_to_game)
		if !client.connected_to_game:
			return taskResult.new(false, "Failed to connect to game")
		return taskResult.new()
	) \
	.stage("Waiting for players to connect...", func():
		await loader.wait_untill(func(): return players_connected == true, -1)
		return taskResult.new()
	) \
	.stage("Initializing game...", func():
		await loader.wait_untill(func(): return initialized == true)
		if !initialized:
			return taskResult.new(false, "Failed to initialize game")
		return taskResult.new()
	) \
	.stage("Waiting for players to be ready...", func(): 
		await loader.wait_untill(func(): return players_ready == true, -1)
		return taskResult.new()
	) \
	.run()
	game.add_child(game.battlefieldRenderer)

func _on_connected_to_server() -> void:
	print("Connected to server")
	connected = true
	reconnectAttempts = 0

func _on_server_disconnect() -> void:
	print("Lost connection to server")
	connected = false

func initialize_connection() -> taskResult:
	if OS.has_feature("web"):
		var host = JavaScriptBridge.eval("window.location.hostname")
		url = "ws://" + host + ":8080/ws"

	while reconnectAttempts < MAX_RECONNECT_ATTEMPS && not connected:
		var err: Error = await reconnect_to_server()
		if err != OK:
			return taskResult.new(false, "Failed to initialize connection: %s" % error_string(err))
		failed = false
		while not connected and not failed:
			await get_tree().process_frame
	
	if failed:
		return taskResult.new(false, "Connection failed")
	
	return taskResult.new()

func reconnect_to_server() -> Error:
	multiplayer.multiplayer_peer = null
	reconnectAttempts += 1
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(url)
	if err != OK:
		return err
	if reconnectAttempts > 1:
		await get_tree().create_timer(2).timeout
	multiplayer.multiplayer_peer = peer
	multiplayer.connection_failed.connect(func(): print("server failed"); failed = true)
	multiplayer.connected_to_server.connect(func(): print("serve connect"); connected = true)
	return OK

func _get_authentication_data() -> Dictionary:
	print(OS.get_cmdline_args())
	if not OS.has_feature("web"):
		return {
		"token": "jwt_local_dummy_text",
		"match_id": get_cmdline_arg("--match_id").to_int(),
		"uuid": get_cmdline_arg("--uuid").to_int()
	}
	js_callback = JavaScriptBridge.create_callback(_on_react_message)
	JavaScriptBridge.get_interface("window")._godotReceiveMessage = js_callback
	JavaScriptBridge.eval("""
		console.log("Executing JavaScriptBridge");
		window.addEventListener('message', function(event) {
		console.log("Godot receive event message")
		let data = event.data;
		if (typeof data === 'string') {
			try {
				data = JSON.parse(data); 
			} catch(e) {
				console.log("Couldn't parse JSON data: ", e)
			}
		}
		if (data && data.type === 'INIT_GAME') {
			console.log("Event data matches")
			window._godotReceiveMessage(JSON.stringify(event.data));
			}
		else {
			console.log("Event data doesn't match")
		}
		});
		console.log("Godot posting message: GODOT_READY")
		window.parent.postMessage({ type: 'GODOT_READY' }, '*');
		""")
	var signal_args = await react_data_received
	return {
		"token": signal_args[0],
		"match_id": get_query_param("match_id").to_int(),
		"uuid": get_query_param("uuid").to_int()
	}
	
func _on_react_message(args) -> void:
	var json_string = args[0]
	if !json_string:
		push_error("Browser sent empty message")
		return
	var parsed_data = JSON.parse_string(json_string)
	if !parsed_data:
		push_error("Failed to parse JSON data from React.")
		return
	var token = parsed_data.get("token", "")
	var match_id = int(parsed_data.get("match_id", "-1"))
	react_data_received.emit(token, match_id)

func get_cmdline_arg(argument: String) -> String:
	var args := OS.get_cmdline_args()
	var index := args.find(argument)

	return args[index + 1]

func get_query_param(name: String) -> String:
	var js := "new URLSearchParams(window.parent.location.search).get('%s')" % name
	return JavaScriptBridge.eval(js)
