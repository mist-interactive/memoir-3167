extends UnitManager
class_name ClientUnitManager

var active_container: Node

func _init(initialState: BattlefieldState) -> void:
	super(initialState)
	Network.Units.sync_unit_requested.connect(_on_sync_unit_requested)
	Network.Units.sync_all_requested.connect(_on_sync_all_requested)
	Network.Units.spawn_unit_requested.connect(_on_unit_spawn_requested)

func _on_sync_unit_requested(snapshot: Dictionary) -> void:
	var uuid: int = snapshot.uuid
	var unit_to_sync: Unit = units_by_id[uuid]
	unit_to_sync.sync_with_snapshot(snapshot)
	unit_grid[unit_to_sync.hex_coord] = uuid

func _on_sync_all_requested(snapshot: Dictionary):
	pass

func _on_unit_spawn_requested(owner_id: int, uuid: int, coord: Vector2i, type: enums.UnitType) -> void:
	print("Unit spawned uuid:", uuid,", type: ", type,", owner: ", owner_id, ",coord: ",coord)
	pass
