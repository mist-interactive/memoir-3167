class_name NetworkClock
extends Node
const TIME_SYNC_INTERVAL := 5.0
var rtt: float # round trip time in ms
var server_time_offset: float
var elapsed: float = 0.0

func _ready() -> void:
	name = "NetworkClock"
	Network.sync_clock_requested.connect(sync)
	Network.sync_clock.rpc_id(1, Time.get_ticks_msec())
	
func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= TIME_SYNC_INTERVAL:
		Network.sync_clock.rpc_id(1, Time.get_ticks_msec())
		elapsed = 0.0

func sync(rtt: float, offset: float) -> void:
	self.rtt = rtt
	self.server_time_offset = offset

func get_server_time() -> float:
	if multiplayer.is_server():
		return Time.get_ticks_msec();
	return Time.get_ticks_msec() + server_time_offset
