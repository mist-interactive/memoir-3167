extends Node
class_name HandNetwork

signal sync_requested(snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_requested.emit(snapshot)
