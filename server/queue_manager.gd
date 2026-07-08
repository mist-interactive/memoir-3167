extends Node
class_name QueueManager
var waiting_players: Array[int] = []
@export var matchManager: MatchManager

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
		matchManager.create_new_match(peerId, peerId2)

func remove_player(peer_id: int) -> void:
	waiting_players.erase(peer_id)
	
