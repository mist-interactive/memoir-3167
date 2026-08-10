extends Node
class_name UnitsNetwork

signal sync_unit_requested(snapshot: Dictionary)
@rpc("authority", "call_remote")
func sync_unit(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_unit_requested.emit(snapshot)

signal sync_all_requested(snapshot: Dictionary)
func sync_all(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	sync_all_requested.emit(snapshot)

signal spawn_unit_requested(owner_id: int, uuid: int, coord: Vector2i, type: enums.UnitType)
@rpc("authority", "call_remote")
func spawn_unit(unit: Dictionary) -> void:
	if multiplayer.is_server():
		return
	spawn_unit_requested.emit(unit.owner_id, unit.uuid, unit.coord, unit.type)
