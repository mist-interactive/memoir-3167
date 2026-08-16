extends UnitManager
class_name ClientUnitManager

var active_container: Node

var UNIT_SCENE = preload("res://client/units/Unit.tscn")

func _init(initialState: BattlefieldState, snapshot: Dictionary = {}) -> void:
	super(initialState)
	Network.Units.sync_unit_requested.connect(_on_sync_unit_requested)
	Network.Units.sync_all_requested.connect(_on_sync_all_requested)
	Network.Units.spawn_unit_requested.connect(_on_spawn_unit_requested)

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
