class_name LogService
extends RefCounted

enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

var level: Level = Level.DEBUG

# Persistent context
var context: Dictionary = {}


func _init(initial_context: Dictionary = {}) -> void:
	context = initial_context.duplicate()


# ---------------------------------------------------------
# Context
# ---------------------------------------------------------

func with_context(extra: Dictionary) -> LogService:
	var child : LogService = LogService.new(context)
	Logger
	for key in extra:
		child.context[key] = extra[key]

	child.level = level

	return child


# ---------------------------------------------------------
# Logging
# ---------------------------------------------------------

func debug(message: String, data: Dictionary = {}) -> void:
	_log(Level.DEBUG, message, data)


func info(message: String, data: Dictionary = {}) -> void:
	_log(Level.INFO, message, data)


func warning(message: String, data: Dictionary = {}) -> void:
	_log(Level.WARNING, message, data)


func error(message: String, data: Dictionary = {}) -> void:
	_log(Level.ERROR, message, data)


func critical(message: String, data: Dictionary = {}) -> void:
	_log(Level.CRITICAL, message, data)


func _log(
	log_level: Level,
	message: String,
	data: Dictionary
) -> void:

	if log_level < level:
		return

	var timestamp := Time.get_datetime_string_from_system(true)

	var level_name := _level_name(log_level)

	var context_string := _format_context()

	var line := "%s [%s] %s %s" % [
		timestamp,
		level_name,
		context_string,
		message
	]

	if not data.is_empty():
		line += " | " + JSON.stringify(data)

	match log_level:
		Level.DEBUG:
			print(line)

		Level.INFO:
			print(line)

		Level.WARNING:
			push_warning(line)

		Level.ERROR:
			push_error(line)

		Level.CRITICAL:
			push_error("!!! " + line)


func _format_context() -> String:
	if context.is_empty():
		return ""

	var result := ""

	# Keep ordering predictable
	var order := [
		"service",
		"match_id",
		"player_id",
		"turn",
		"request_id",
		"connection_id",
		"component"
	]
	if context.has("service"):
		result += "[%s] " % [context.service]
	for key in order:
		if context.has(key) && key != "service":
			result += "[%s:%s] " % [
				key,
				str(context[key])
			]

	# Include any custom context
	for key in context:
		if key not in order:
			result += "[%s:%s]" % [
				key.to_upper(),
				str(context[key])
			]

	return result.strip_edges()


func _level_name(log_level: Level) -> String:
	match log_level:
		Level.DEBUG:
			return "DEBUG"

		Level.INFO:
			return "INFO"

		Level.WARNING:
			return "WARN"

		Level.ERROR:
			return "ERROR"

		Level.CRITICAL:
			return "CRITICAL"

	return "UNKNOWN"
