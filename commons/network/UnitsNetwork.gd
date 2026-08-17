extends Node
class_name UnitsNetwork

signal sync_unit_requested(snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync_unit(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_unit_requested.emit(snapshot)

signal sync_all_requested(snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync_all(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_all_requested.emit(snapshot)

signal spawn_unit_requested(unit: Dictionary)
@rpc("authority", "call_remote")
func spawn_unit(unit: Dictionary) -> void:
	if multiplayer.is_server():
		return
	spawn_unit_requested.emit(unit)
