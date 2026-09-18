class_name ConfigLoader

static func load_json(src: String) -> Dictionary:
	if not FileAccess.file_exists(src):
		return {}

	var file = FileAccess.open(src, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())

	if json is Dictionary:
		return json
	
	return {}
