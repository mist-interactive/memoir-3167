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

@rpc("any_peer", "call_remote")
func sync_clock(client_time: float) -> void:
	var server_time: float = Time.get_ticks_msec()
	Network.sync_clock_response.rpc_id(multiplayer.get_remote_sender_id(),server_time, client_time)
	
signal sync_clock_requested(rtt: float, offset_time: float)
@rpc("authority", "call_remote")
func sync_clock_response(server_time: float, client_sent_time: float) -> void:
	var now: float = Time.get_ticks_msec()
	var rtt: float = now - client_sent_time
	var offset_time: float = server_time - (client_sent_time + rtt/2)
	sync_clock_requested.emit(rtt, offset_time)
