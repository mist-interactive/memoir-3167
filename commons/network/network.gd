extends Node
@export var Match: MatchNetwork
@export var Actions: ActionsNetwork
@export var Client: ClientNetwork
@export var Hand: HandNetwork
@export var Units: UnitsNetwork

signal join_queue_requested(peer_id: int, uuid: int)

@rpc("any_peer","call_remote")
func join_queue(uuid: int) -> void:
	join_queue_requested.emit(multiplayer.get_remote_sender_id(), uuid)
