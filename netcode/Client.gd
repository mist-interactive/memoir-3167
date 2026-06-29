class_name Client
var ws: WebSocketPeer;
var game: Game;
var authToken: String;

func _init(_ws: WebSocketPeer) -> void:
	ws = _ws
