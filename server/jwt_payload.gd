class_name JwtPayload

var header: Dictionary
var payload: Dictionary

func _init(p_header: Dictionary, p_payload: Dictionary) -> void:
	header = p_header
	payload = p_payload
