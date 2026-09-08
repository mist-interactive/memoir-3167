class_name MemoirApi
extends BackendApi
var logger: LogService
@export var server: Server
var API_KEY_PATH: String = "/run/secrets/internal_api_key"
var api_key: String

func _ready() -> void:
	base_url = "http://go-server:8080/api"
	logger = server.logger.with_context({"component": "memoirApi"})
	if OS.has_feature("editor"):
		return
	api_key = load_api_key()
	assert(!api_key.is_empty())
	logger.error("api key: %s" % api_key)

func _init(base_url: String = "") -> void:
	super(base_url)

func load_api_key() -> String:
	var file = FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file:
		return file.get_as_text()
	return file.get_as_text() + "xdd"

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
	logger.error("api: key %s" % api_key)
	var res: Response = await patch("/internal/matches/%d" % result.match_id, body, ["x-api-key: %s" %api_key])
	if !res.success:
		logger.error("failed to post match result, api key %s" % api_key, res.to_dict())
		return
	logger.info("response: ", res.to_dict())
