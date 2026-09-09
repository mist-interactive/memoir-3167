class_name MemoirApi
extends BackendApi
var logger: LogService
@export var server: Server
var API_KEY_PATH: String = "/run/secrets/internal_api_key"
var api_key: String
var is_ready: bool = true

func _ready() -> void:
	logger = server.logger.with_context({"component": "memoirApi"})
	if OS.has_feature("editor"):
		return
	api_key = load_api_key()
	is_ready = !api_key.is_empty()
	if !is_ready:
		logger.error("Failed to load api key")

func _init(base_url: String = "") -> void:
	base_url = "http://go-server:8080/api"
	super(base_url)

func load_api_key() -> String:
	var file = FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file:
		return file.get_as_text().strip_edges()
	return ""

func post_match_results(result: MatchResult) -> void:
	if OS.has_feature("editor"):
		return
	logger.info("posting match result", result.to_dict())
	var scores: Array[Dictionary]
	for uuid in result.scores:
		scores.append({"player_id": uuid, "score": result.scores[uuid]})
	var body: Dictionary = {
		"scores": scores,
		"status": "finished"
	}
	var res: Response = await patch("/internal/matches/%d" % result.match_id, body, ["x-api-key: %s" % api_key])
	if !res.success:
		logger.error("failed to post match result, api key %s" % api_key, res.to_dict())
		return
	logger.info("response: ", res.to_dict())
