extends Node
class_name Server

const JWT_PUBLIC_KEY_PATH := "/run/secrets/jwt_public_key"

var peer: WebSocketMultiplayerPeer
var port: int = 6669
var clients: Dictionary[int, ClientState]
var sessions: Dictionary[int, int] # uuid -> peer_id
var logger: LogService

var jwt_public_key: CryptoKey

func _ready() -> void:
	name = "SERVER"
	logger = LogService.new({"service": "server"})

	logger.info("=== SERVER STARTING ===")
	logger.info("OS feature editor: %s" % OS.has_feature("editor"))
	logger.info("OS feature web: %s" % OS.has_feature("web"))

	if not OS.has_feature("editor"):
		logger.info("Loading JWT public key...")
		_load_jwt_public_key()
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


func _load_jwt_public_key() -> void:
	jwt_public_key = CryptoKey.new()

	if not FileAccess.file_exists(JWT_PUBLIC_KEY_PATH):
		push_error("JWT public key file does not exist: %s" % JWT_PUBLIC_KEY_PATH)
		get_tree().quit(1)
		return

	var error: Error = jwt_public_key.load(JWT_PUBLIC_KEY_PATH, true)

	if error != OK:
		push_error("Failed to load JWT public key: %d" % error)
		get_tree().quit(1)
		return

	logger.info("JWT public key loaded successfully")


func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: ClientState = clients[peer_id]
		client.sync()


func _on_peer_connected(id: int) -> void:
	logger.info("=== CLIENT CONNECTED ===")
	logger.info("Peer ID: %d" % id)

	logger.info("A new client has connected", {"uuid": id})
	clients[id] = ClientState.new(id)


func _on_peer_disconnected(id: int) -> void:
	logger.info("=== CLIENT DISCONNECTED ===")
	logger.info("Peer ID: %d" % id)

	logger.info("Client has disconnected", {"uuid": id})
	clients.erase(id)


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

	var exp := _get_jwt_expiration(jwt_token)

	if exp == -1:
		client.authenticated = false
		logger.info("Client %d authentication failed: no valid expiration" % peer_id)
		return

	var current_time := Time.get_unix_time_from_system()

	logger.info("JWT expires at Unix timestamp: %s" % exp)
	logger.info("Current Unix timestamp: %s" % current_time)

	if exp <= current_time:
		client.authenticated = false
		logger.info("Client %d authentication failed: JWT expired" % peer_id)
		return

	if _verify_jwt(jwt_token):
		client.authenticated = true
		logger.info("Client %d authenticated" % peer_id)
	else:
		client.authenticated = false
		logger.info("Client %d authentication failed" % peer_id)


func _verify_jwt(token: String) -> bool:
	if jwt_public_key == null:
		push_error("JWT public key is not loaded")
		return false

	var parts: PackedStringArray = token.split(".")

	if parts.size() != 3:
		logger.info("Invalid JWT format")
		return false

	var encoded_header: String = parts[0]
	var encoded_payload: String = parts[1]
	var encoded_signature: String = parts[2]

	# Decode header.
	var header_bytes: PackedByteArray = _base64url_decode(encoded_header)

	if header_bytes.is_empty():
		logger.info("Invalid JWT header")
		return false

	var header_value: Variant = JSON.parse_string(
		header_bytes.get_string_from_utf8()
	)

	if typeof(header_value) != TYPE_DICTIONARY:
		logger.info("Invalid JWT header JSON")
		return false

	var header: Dictionary = header_value

	if header.get("alg", "") != "RS256":
		logger.info("Unsupported JWT algorithm")
		return false

	# Decode payload.
	var payload_bytes: PackedByteArray = _base64url_decode(encoded_payload)

	if payload_bytes.is_empty():
		logger.info("Invalid JWT payload")
		return false

	var payload_value: Variant = JSON.parse_string(
		payload_bytes.get_string_from_utf8()
	)

	if typeof(payload_value) != TYPE_DICTIONARY:
		logger.info("Invalid JWT payload JSON")
		return false

	var payload: Dictionary = payload_value

	# Decode signature.
	var signature: PackedByteArray = _base64url_decode(encoded_signature)

	if signature.is_empty():
		logger.info("Invalid JWT signature")
		return false

	# JWT signs exactly:
	#
	# base64url(header) + "." + base64url(payload)
	#
	var signing_input: PackedByteArray = (
		encoded_header + "." + encoded_payload
	).to_utf8_buffer()

	# Verify RSA + SHA-256 signature.
	var crypto: Crypto = Crypto.new()

	var valid: bool = crypto.verify_hash(
		HashingContext.HASH_SHA256,
		signing_input,
		signature,
		jwt_public_key
	)

	if not valid:
		logger.info("Invalid JWT signature")
		return false

	# Check expiration.
	if payload.has("exp"):
		var exp_value: Variant = payload["exp"]

		if typeof(exp_value) != TYPE_INT and typeof(exp_value) != TYPE_FLOAT:
			logger.info("Invalid JWT exp claim")
			return false

		var expiration: float = float(exp_value)
		var now: float = Time.get_unix_time_from_system()

		if expiration <= now:
			logger.info("JWT has expired")
			return false

	logger.info("JWT verified successfully")

	return true


func _base64url_decode(value: String) -> PackedByteArray:
	var normalized := value.replace("-", "+").replace("_", "/")

	# Base64 requires padding to a multiple of 4.
	while normalized.length() % 4 != 0:
		normalized += "="

	return Marshalls.base64_to_raw(normalized)


func _get_jwt_expiration(jwt_token: String) -> int:
	var parts := jwt_token.split(".")

	if parts.size() != 3:
		return -1

	var payload_b64 := parts[1]
	payload_b64 = payload_b64.replace("-", "+").replace("_", "/")

	while payload_b64.length() % 4 != 0:
		payload_b64 += "="

	var payload_bytes := Marshalls.base64_to_raw(payload_b64)
	var payload_string := payload_bytes.get_string_from_utf8()
	var json = JSON.parse_string(payload_string)

	if typeof(json) != TYPE_DICTIONARY:
		return -1

	if not json.has("exp"):
		return -1

	return int(json["exp"])
