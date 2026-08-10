extends UnitManager
class_name ClientUnitManager

var active_container: Node

var UNIT_SCENE = preload("res://client/units/Unit.tscn")

func _init(initialState: BattlefieldState) -> void:
	super(initialState)
	Network.Units.sync_unit_requested.connect(_on_sync_unit_requested)
	Network.Units.sync_all_requested.connect(_on_sync_all_requested)
	Network.Units.spawn_unit_requested.connect(_on_spawn_unit_requested)

func _on_sync_unit_requested(snapshot: Dictionary) -> void:
	var uuid: int = snapshot.uuid
	var unit_to_sync: Unit = units_by_id[uuid]
	unit_to_sync.sync_with_snapshot(snapshot)
	unit_grid[unit_to_sync.hex_coord] = uuid

func _on_sync_all_requested(snapshot: Dictionary):
	pass

func _on_spawn_unit_requested(owner_id: int, uuid: int, coord: Vector2i, type: enums.UnitType) -> void:
	#print("Unit spawned uuid:", uuid,", type: ", type,", owner: ", owner_id, ",coord: ",coord)
	var new_unit = UNIT_SCENE.instantiate() as Unit
	active_container.add_child(new_unit)
	add_unit(new_unit, coord)
	new_unit.setup(owner_id, type, uuid, coord)
	pass
