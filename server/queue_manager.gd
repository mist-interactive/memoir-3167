extends Node
class_name QueueManager
var waiting_players: Array[int] = []
@onready var Match = preload("res://server/Match.tscn")
@onready var matchManager = $"../MatchManager"

func _ready() -> void:
	Network.join_queue_requested.connect(enqueue_player)
	
func enqueue_player(peer_id: int) -> void:
	if peer_id in waiting_players:
		return
	print("enqueued player: ", peer_id)
	waiting_players.append(peer_id)
	if waiting_players.size() >= 2:
		var peerId = waiting_players.pop_front()
		var peerId2 = waiting_players.pop_front()
		var matchState = MatchState.new()
		matchState.player_ids.append_array([peerId, peerId2])
		matchManager.create_new_match(peerId, peerId2)
		#Network.create_match_requested.emit(matchState)

func remove_player(peer_id: int) -> void:
	waiting_players.erase(peer_id)
