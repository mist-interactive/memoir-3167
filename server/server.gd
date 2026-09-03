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

	_load_jwt_public_key()

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Network.Client.auth_check_requested.connect(_on_auth_check_requested)

	peer = WebSocketMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
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

	print("JWT public key loaded successfully")

func _physics_process(delta: float) -> void:
	for peer_id in clients.keys():
		var client: ClientState = clients[peer_id]
		client.sync()

func _on_peer_connected(id: int) -> void:
	logger.info("A new client has connected", {"uuid": id})
	clients[id] = ClientState.new(id)

func _on_peer_disconnected(id: int) -> void:
	logger.info("Clien has disconnected", {"uuid": id})
	clients.erase(id)

func _on_auth_check_requested(peer_id: int, jwt_token: String) -> void:
	print("Authenticating client %d..." % peer_id)

	var client: ClientState = clients.get(peer_id)

	if client == null:
		return

	if _verify_jwt(jwt_token):
		client.authenticated = true
		print("Client %d authenticated" % peer_id)
	else:
		client.authenticated = false
		print("Client %d authentication failed" % peer_id)

func _verify_jwt(token: String) -> bool:
	if jwt_public_key == null:
		push_error("JWT public key is not loaded")
		return false

	var parts: PackedStringArray = token.split(".")

	if parts.size() != 3:
		print("Invalid JWT format")
		return false

	var encoded_header: String = parts[0]
	var encoded_payload: String = parts[1]
	var encoded_signature: String = parts[2]

	# Decode header.
	var header_bytes: PackedByteArray = _base64url_decode(encoded_header)

	if header_bytes.is_empty():
		print("Invalid JWT header")
		return false

	var header_value: Variant = JSON.parse_string(
		header_bytes.get_string_from_utf8()
	)

	if typeof(header_value) != TYPE_DICTIONARY:
		print("Invalid JWT header JSON")
		return false

	var header: Dictionary = header_value

	if header.get("alg", "") != "RS256":
		print("Unsupported JWT algorithm")
		return false

	# Decode payload.
	var payload_bytes: PackedByteArray = _base64url_decode(encoded_payload)

	if payload_bytes.is_empty():
		print("Invalid JWT payload")
		return false

	var payload_value: Variant = JSON.parse_string(
		payload_bytes.get_string_from_utf8()
	)

	if typeof(payload_value) != TYPE_DICTIONARY:
		print("Invalid JWT payload JSON")
		return false

	var payload: Dictionary = payload_value

	# Decode signature.
	var signature: PackedByteArray = _base64url_decode(encoded_signature)

	if signature.is_empty():
		print("Invalid JWT signature")
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
		print("Invalid JWT signature")
		return false

	# Check expiration.
	if payload.has("exp"):
		var exp_value: Variant = payload["exp"]

		if typeof(exp_value) != TYPE_INT and typeof(exp_value) != TYPE_FLOAT:
			print("Invalid JWT exp claim")
			return false

		var expiration: float = float(exp_value)
		var now: float = Time.get_unix_time_from_system()

		if expiration <= now:
			print("JWT has expired")
			return false

	print("JWT verified successfully")

	return true


func _base64url_decode(value: String) -> PackedByteArray:
	var normalized := value.replace("-", "+").replace("_", "/")

	# Base64 requires padding to a multiple of 4.
	while normalized.length() % 4 != 0:
		normalized += "="

	return Marshalls.base64_to_raw(normalized)
