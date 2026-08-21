extends Node
class_name PlayerController

@onready var battlefieldState: BattlefieldState = $"../../BattlefieldState"
@onready var matchState: MatchState = $"../../matchState"
@export var map_ground_layer: TileMapLayer
@export var map_feature_layer: TileMapLayer
@export var unit_selection_highlight_layer: TileMapLayer
@export var unit_path_highlight_layer: TileMapLayer
@export var sector_highlight_layer: TileMapLayer
@onready var unit_manager: ClientUnitManager = $"../../UnitManager"

var is_my_turn: bool = false
var _active_came_from: Dictionary = {}
var _selected_hex: Vector2i = Vector2i(-1, -1)
var _selected_unit: Unit = null

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Handling left click")
		_handle_left_click()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_right_click()

func _handle_left_click() -> void:
	var click_position: Vector2 = map_ground_layer.get_global_mouse_position()
	var hex: Vector2i = map_ground_layer.local_to_map(map_ground_layer.to_local(click_position))
	# Check if selected hex is actually on the gameboard
	var cell_source_id := map_ground_layer.get_cell_source_id(hex)
	if cell_source_id == -1:
		_clear_selection()
		return
	var unit: Unit = unit_manager.get_unit_at(hex)
	if unit:
		_selected_hex = hex
		_selected_unit = unit
		var unit_stats: UnitStats = UnitDatabase.get_stats(_selected_unit.type)
		var path_data = BoardPathfinding.get_reachable_hexes(unit_stats.type, _selected_hex, battlefieldState.map, unit_manager.get_occupied_coords())
		_active_came_from = path_data.get("came_from", {})
		_highlight_unit_reachable_hexes(path_data, _selected_hex)
		if matchState.is_my_turn() && (matchState.phase == enums.TurnPhase.SELECT || matchState.phase == enums.TurnPhase.MOVE || matchState.phase == enums.TurnPhase.ATTACK):
			var is_my_unit: bool = unit.owner_id == matchState.mySide
			if is_my_unit:
				Network.Actions.select_unit.rpc_id(1, unit_manager.get_unit_at(_selected_hex).uuid)
	else:
		_clear_selection()

func _handle_right_click() -> void:
	if _selected_unit == null or not matchState.is_my_turn():
		print("No unit selected or not my turn")
		return
	var click_position: Vector2 = map_ground_layer.get_global_mouse_position()
	var target_hex: Vector2i = map_ground_layer.local_to_map(map_ground_layer.to_local(click_position))
	# Check if selected hex is actually on the gameboard
	var cell_source_id := map_ground_layer.get_cell_source_id(target_hex)
	if cell_source_id == -1:
		print("Wrong cell")
		return
	print("Phase: ", matchState.phase)
	print("Move phase: ", enums.TurnPhase.MOVE)
	match matchState.phase:
		enums.TurnPhase.MOVE:
			print("Move phase")
			var is_my_unit: bool = _selected_unit && _selected_unit.owner_id == matchState.mySide
			if !is_my_unit:
				print("Not my unit selected")
				return
			if not _active_came_from.has(target_hex):
				print("Can't reach hex: ", target_hex)
				return
			Network.Actions.move_unit.rpc_id(1, unit_manager.selected_unit_id, target_hex)
			_clear_selection()
		enums.TurnPhase.ATTACK:
			if not _selected_unit:
				print("No unit selected")
				return
			var is_my_unit: bool = _selected_unit && _selected_unit.owner_id == matchState.mySide
			if not is_my_unit:
				return
			var target_unit: Unit = unit_manager.get_unit_at(target_hex)
			if target_unit and target_unit.owner_id != matchState.mySide:
				Network.Actions.attack_unit.rpc_id(1, unit_manager.selected_unit_id, target_unit.uuid)
				_clear_selection()

func _on_card_hovered(card_target: enums.MapSector) -> void:
	var hexes_to_highlight: Array[Vector2i] = []
	for sector_key: enums.MapSector in battlefieldState.sector_index:
		if (sector_key & card_target) != 0:
			var coords_in_sector: Array = battlefieldState.sector_index[sector_key]
			for pos: Vector2i in coords_in_sector:
				hexes_to_highlight.append(pos)
	_apply_sector_highlights(hexes_to_highlight)

func _apply_sector_highlights(hexes: Array[Vector2i]) -> void:
	for hex in hexes:
		sector_highlight_layer.set_cell(hex, 0, Vector2i(0, 0))

func _on_card_unhovered() -> void:
	sector_highlight_layer.clear()

#NOTE: Testing for UnitDatabase. Can be removed later! vvv
func _print_unit_stats(unit_stats: UnitStats) -> void:
	print("Unit type: ", enums.UnitType.find_key(unit_stats.type))
	print("Unit max movement: ", unit_stats.max_movement)
	print("Unit max movement and attack: ", unit_stats.max_movement_and_attack)
	print("Unit can move and attack: ", unit_stats.can_move_and_attack)
	print("Unit health: ", unit_stats.max_health)
	print("Unit max attack range: ", unit_stats.max_attack_range)
	for i in range(0, unit_stats.attack_dice_by_distance.size()):
		print("Unit's attack dice to distance %s is %s" % [i + 1, unit_stats.attack_dice_by_distance[i]])
	print("Unit can overrun: ", unit_stats.can_overrun)
	print("Unit can take ground: ", unit_stats.can_take_ground)
	

func _clear_selection() -> void:
	_selected_hex = Vector2i(-1, -1)
	_selected_unit = null
	_active_came_from.clear()
	unit_path_highlight_layer.clear()

func _highlight_unit_reachable_hexes(path_data: Dictionary, hex: Vector2i) -> void:
	unit_path_highlight_layer.clear()
	var reachable_costs: Dictionary = path_data.get("costs", {})
	for coord in reachable_costs.keys():
		unit_path_highlight_layer.highlight_cell(coord)
