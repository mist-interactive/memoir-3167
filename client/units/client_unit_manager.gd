extends UnitManager
class_name ClientUnitManager

var active_container: Node

var UNIT_SCENE = preload("res://client/units/Unit.tscn")

func _init(initialState: BattlefieldState) -> void:
	super(initialState)
	Network.Units.sync_unit_requested.connect(_on_sync_unit_requested)
	Network.Units.sync_all_requested.connect(_on_sync_all_requested)
	Network.Units.spawn_unit_requested.connect(_on_spawn_unit_requested)
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result_requested)
	Network.Actions.sync_unit_path_received.connect(_on_sync_unit_path_received)
	Network.Units.unit_destroyed_requested.connect(_on_unit_destroyed)
	
# snapshot used for reconnection
func initialize(active_container: Node, snapshot: Dictionary = {}) -> void:
	self.active_container = active_container
	if !snapshot.is_empty() && snapshot.has("units"):
		print("snapshot.units", snapshot.units)
		for unit: Dictionary in snapshot.units:
			_on_spawn_unit_requested(unit)

func _on_sync_unit_requested(snapshot: Dictionary) -> void:
	var uuid: int = snapshot.uuid
	var unit_to_sync: Unit = units_by_id[uuid]
	unit_to_sync.sync_with_snapshot(snapshot)
	unit_grid[unit_to_sync.hex_coord] = uuid

func _on_sync_all_requested(snapshot: Dictionary):
	selected_unit_id = snapshot.selected_unit_id
	selected_by_peer = snapshot.selected_by_peer
	selected_units_ids = snapshot.selected_units_ids
	moved_units_ids = snapshot.moved_units_ids
	attacked_units_ids = snapshot.attacked_units_ids
	unit_grid.clear()
	for unit: Unit in units_by_id.values():
		unit_grid[unit.hex_coord] = unit.uuid

func _on_spawn_unit_requested(unit: Dictionary) -> void:
	var new_unit = UNIT_SCENE.instantiate() as Unit
	new_unit.name = "unit_" + str(unit.uuid)
	active_container.add_child(new_unit)
	new_unit.setup(unit.owner_id, unit.type, unit.uuid, unit.coord)
	add_unit(new_unit, unit.coord)
	pass

func _on_resolve_combat_result_requested(result: CombatResult) -> void:
	print("Combat result: ", result.to_dict())

func _on_sync_unit_path_received(unit_id: int, path: Array[Vector2i]) -> void:
	var unit: Unit = units_by_id[unit_id]
	if !unit:
		return
	unit.move_along_path(path)
	
func _on_unit_destroyed(unit_id: int) -> void:
	var unit: Unit = units_by_id[unit_id]
	unit.queue_free()
	unit_grid.erase(unit.hex_coord)
	units_by_id.erase(unit_id)
