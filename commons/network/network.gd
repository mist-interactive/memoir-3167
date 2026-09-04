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

func broadcast(rpc_func: Callable, peer_ids: Array[int], args: Array = []) -> void:
	for peer_id in peer_ids:
		if peer_id < 0:
			continue
		var tmp_args: Array
		tmp_args.assign(args)
		tmp_args.push_front(peer_id)
		rpc_func.callv(tmp_args)
