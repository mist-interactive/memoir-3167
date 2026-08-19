extends Node
class_name PlayerController

@onready var battlefieldState: BattlefieldState = $"../../BattlefieldState"
@onready var matchState: MatchState = $"../../matchState"
@export var map_ground_layer: TileMapLayer
@export var map_feature_layer: TileMapLayer
@export var map_highlight_layer: TileMapLayer
@export var sector_highlight_layer: TileMapLayer
@onready var unit_manager: ClientUnitManager = $"../../UnitManager"
var is_my_turn: bool = false

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	#if not is_my_turn:
		#return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()

func _handle_left_click() -> void:
	var click_position: Vector2 = map_ground_layer.get_global_mouse_position()
	var hex: Vector2i = map_ground_layer.local_to_map(map_ground_layer.to_local(click_position))
	# Check if selected hex is actually on the gameboard
	var cell_source_id := map_ground_layer.get_cell_source_id(hex)
	
	#NOTE: Testing for UnitDatabase and pathfinding. Can be removed later! vvv
	var unit_clicked: Unit = unit_manager.get_unit_at(hex)
	if unit_clicked:
		var unit_stats: UnitStats = UnitDatabase.get_stats(unit_clicked.type)
		_print_unit_stats(unit_stats)
		_highlight_unit_reachable_hexes(unit_stats, hex)
	#NOTE: Testing for UnitDatabase and pathfinding. Can be removed later! vvv
	
	if cell_source_id == -1 || !matchState.is_my_turn():
		return
	match matchState.phase:
		enums.TurnPhase.MOVE:
			var unit: Unit = unit_manager.get_unit_at(hex)
			var is_my_unit: bool = unit && unit.owner_id == matchState.mySide
			if !is_my_unit && unit:
				return
			Network.Match.request_hex_selection.rpc_id(1, hex)
			if is_my_unit:
				Network.Actions.select_unit.rpc_id(1, unit_manager.get_unit_at(hex).uuid)
			else:
				Network.Actions.move_unit.rpc_id(1, unit_manager.selected_unit_id, hex)
		enums.TurnPhase.ATTACK:
			var unit: Unit = unit_manager.get_unit_at(hex)
			if !unit:
				return
			var is_my_unit: bool = unit && unit.owner_id == matchState.mySide
			Network.Match.request_hex_selection.rpc_id(1, hex)
			if is_my_unit:
				Network.Actions.select_unit.rpc_id(1, unit_manager.get_unit_at(hex).uuid)
			else:
				Network.Actions.attack_unit.rpc_id(1, unit_manager.selected_unit_id, unit.uuid)

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
	print("Unit health: ", unit_stats.health)
	print("Unit max attack range: ", unit_stats.max_attack_range)
	for i in range(0, unit_stats.attack_dice_by_distance.size()):
		print("Unit's attack dice to distance %s is %s" % [i + 1, unit_stats.attack_dice_by_distance[i]])
	print("Unit can overrun: ", unit_stats.can_overrun)
	print("Unit can take ground: ", unit_stats.can_take_ground)
	
func _highlight_unit_reachable_hexes(unit_stats: UnitStats, hex: Vector2i) -> void:
	var path_data = BoardPathfinding.get_reachable_hexes(unit_stats.type, hex, battlefieldState.map, unit_manager.get_occupied_coords())
	map_highlight_layer.clear()
	var reachable_costs: Dictionary = path_data.get("costs", {})
	for coord in reachable_costs.keys():
		map_highlight_layer.highlight_cell(coord)
#NOTE: Testing for UnitDatabase. Can be removed later! ^^^
