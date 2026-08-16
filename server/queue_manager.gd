extends Node
class_name QueueManager
var waiting_players: Array[int] = []
var waiting_players_uuids: Array[int] = []
@export var matchManager: MatchManager

func _ready() -> void:
	Network.join_queue_requested.connect(enqueue_player)
	
func enqueue_player(peer_id: int, uuid: int) -> void:
	if matchManager.uuid_to_peer.has(uuid) && matchManager.peer_to_match.has(matchManager.uuid_to_peer[uuid]):
		matchManager.reconnect(peer_id, uuid)
		return
	if peer_id in waiting_players:
		return
	waiting_players.append(peer_id)
	waiting_players_uuids.append(uuid)
	if waiting_players.size() >= 2:
		var peerId = waiting_players.pop_front()
		var peerId2 = waiting_players.pop_front()
		var uuid1 = waiting_players_uuids.pop_front()
		var uuid2 = waiting_players_uuids.pop_front()
		matchManager.create_new_match(peerId, peerId2, uuid1, uuid2)

func remove_player(peer_id: int) -> void:
	waiting_players.erase(peer_id)
	
