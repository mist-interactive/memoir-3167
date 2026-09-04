extends RefCounted
class_name JwtVerifier

const JWT_PUBLIC_KEY_PATH := "/run/secrets/jwt_public_key"
var logger: LogService
var public_key: CryptoKey
var is_ready: bool = false

func _init(p_logger: LogService) -> void:
	logger = p_logger
	if OS.has_feature("editor"):
		is_ready = true
		return
	logger.info("Loading JWT public key...")
	is_ready = _load_public_key()

func _load_public_key() -> bool:
	public_key = CryptoKey.new()
	if not FileAccess.file_exists(JWT_PUBLIC_KEY_PATH):
		logger.error("JWT public key file does not exist: %s" % JWT_PUBLIC_KEY_PATH)
		return false
		
	var error := public_key.load(JWT_PUBLIC_KEY_PATH, true)
	if error != OK:
		logger.error("Failed to load JWT public key: %d" % error)
		return false
		
	logger.info("JWT public key loaded successfully")
	return true

func verify(token: String) -> bool:
	if not is_ready:
		logger.info("JWT verifier is not ready")
		return false

	if public_key == null:
		logger.error("JWT public key is not loaded")
		return false

	var parts := token.split(".")
	if parts.size() != 3:
		logger.info("Invalid JWT format")
		return false

	var encoded_header := parts[0]
	var encoded_payload := parts[1]
	var encoded_signature := parts[2]
	var header := _decode_json(encoded_header)

	if header.is_empty():
		logger.info("Invalid JWT header")
		return false

	if header.get("alg", "") != "RS256":
		logger.info("Unsupported JWT algorithm")
		return false

	logger.info("JWT header", header)
	var payload := _decode_json(encoded_payload)
	if payload.is_empty():
		logger.info("Invalid JWT payload")
		return false

	var signature := _base64url_decode(encoded_signature)
	if signature.is_empty():
		logger.info("Invalid JWT signature")
		return false

	var signing_input := encoded_header + "." + encoded_payload
	var digest := signing_input.sha256_buffer()
	var crypto := Crypto.new()
	var valid := crypto.verify(
		HashingContext.HASH_SHA256,
		digest,
		signature,
		public_key
	)
	if not valid:
		logger.info("Invalid JWT signature")
		return false

	if not _validate_expiration(payload):
		return false
	logger.info("JWT verified successfully")
	return true


func _validate_expiration(payload: Dictionary) -> bool:
	if not payload.has("exp"):
		logger.info("JWT has no expiration")
		return false
		
	var exp_value: Variant = payload["exp"]
	if typeof(exp_value) != TYPE_INT and typeof(exp_value) != TYPE_FLOAT:
		logger.info("Invalid JWT exp claim")
		return false
		
	var expiration := float(exp_value)
	var now := Time.get_unix_time_from_system()
	if expiration <= now:
		logger.info("JWT has expired")
		return false
		
	return true


func _decode_json(encoded_value: String) -> Dictionary:
	var bytes := _base64url_decode(encoded_value)
	if bytes.is_empty():
		return {}
		
	var value: Variant = JSON.parse_string(
		bytes.get_string_from_utf8()
	)
	if typeof(value) != TYPE_DICTIONARY:
		return {}
		
	return value

func _base64url_decode(value: String) -> PackedByteArray:
	var normalized := value.replace("-", "+").replace("_", "/")
	while normalized.length() % 4 != 0:
		normalized += "="
	return Marshalls.base64_to_raw(normalized)
