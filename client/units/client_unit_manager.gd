extends UnitManager
class_name ClientUnitManager

var active_container: Node
@onready var match_state: MatchState = $"../matchState"
var UNIT_SCENE = preload("res://client/units/Unit.tscn")
var map_manager: ClientMapManager

func _init(initialState: BattlefieldState) -> void:
	super(initialState)
	Network.Units.sync_unit_requested.connect(_on_sync_unit_requested)
	Network.Units.sync_all_requested.connect(_on_sync_all_requested)
	Network.Units.spawn_unit_requested.connect(_on_spawn_unit_requested)
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result_requested)
	unit_selected.connect(_on_unit_selected)
	
# snapshot used for reconnection
func initialize(active_container: Node, map_manager: ClientMapManager, snapshot: Dictionary = {}) -> void:
	self.active_container = active_container
	self.map_manager = map_manager
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

func _on_resolve_combat_result_requested(result: CombatResult) -> void:
	var uuid: int = result.unit_ids[enums.Side.RED] if enums.Side.GREEN == result.target else result.unit_ids[enums.Side.GREEN]
	var assault_unit: Unit = units_by_id[uuid]
	var target_uuid: int = result.unit_ids[result.target]
	var world_pos: Vector2 =  map_manager.get_unit_world_pos(units_by_id[target_uuid].hex_coord)
	if assault_unit.type == enums.UnitType.TANK:
		assault_unit.get_node("./Tank").attack(world_pos, result.dmg)

func _on_unit_selected(unit_id: int, prev_unit_id: int) -> void:
	if match_state.phase == enums.TurnPhase.ATTACK && unit_id != -1 && units_by_id[unit_id].type == enums.UnitType.TANK:
		units_by_id[unit_id].get_node("./Tank").scan()
