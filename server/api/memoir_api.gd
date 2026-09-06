class_name MemoirApi
extends BackendApi
var logger: LogService
@export var server: Server

func _ready() -> void:
	base_url = "http://localhost:8443/api"
	logger = server.logger.with_context({"component": "memoirApi"})

func _init(base_url: String = "") -> void:
	super(base_url)

func post_match_results(result: MatchResult) -> void:
	logger.info("posting match result", result.to_dict())
	var res: Response = await patch("/internal/match/%d" % result.match_id, result.to_dict())
	if !res.success:
		logger.error("failed to post match result", res.to_dict())
		return
	logger.info("response: ", res.to_dict())
