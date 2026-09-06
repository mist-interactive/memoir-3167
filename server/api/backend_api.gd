class_name BackendApi
extends Node
var base_url: String
var http: HTTPRequest

func _init(base_url: String = "") -> void:
	self.base_url = base_url
	http = HTTPRequest.new()
	add_child(http)

func get_request(path: String) -> Response:
	return await _request(HTTPClient.METHOD_GET, path)

func post(path: String, data: Dictionary) -> Response:
	return await _request(
		HTTPClient.METHOD_POST,
		path,
		data
	)

func patch(path: String, data: Dictionary) -> Response:
	return await _request(
		HTTPClient.METHOD_PATCH,
		path,
		data
	)

func _request(
	method: HTTPClient.Method,
	path: String,
	data: Dictionary = {}
) -> Response:
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	var body := ""
	if not data.is_empty():
		body = JSON.stringify(data)
	var url: String = base_url + path
	var error = http.request(
		url,
		headers,
		method,
		body
	)

	if error != OK:
		return Response._error(url, error_string(error))

	var res = await http.request_completed

	var result = res[0]
	var status_code = res[1]
	var res_body = res[3]
	var parsed_res_body = JSON.parse_string(res_body.get_string_from_utf8())
	var success: bool = result == HTTPRequest.RESULT_SUCCESS and status_code >= 200 and status_code < 300
	return Response.new(url, success, status_code, parsed_res_body)
