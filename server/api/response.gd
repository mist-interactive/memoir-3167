class_name Response
extends RefCounted

var url: String
var success: bool
var code: HTTPClient.ResponseCode
var body: Variant
var error: String

func _init(url: String, success: bool, code: HTTPClient.ResponseCode, body: Variant = null) -> void:
	self.success = success
	self.code = code
	self.body = body
	self.url = url

static func _error(url: String, err_string: String) -> Response:
	var res: Response = Response.new(url, false, 500)
	res.error = err_string
	return res

func to_dict() -> Dictionary:
	return {
		"url": url,
		"success": success,
		"code": code,
		"body": body,
		"error": error
	}
