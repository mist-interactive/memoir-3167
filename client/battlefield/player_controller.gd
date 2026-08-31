extends Node
class_name PlayerController

@onready var battlefieldState: BattlefieldState = $"../../BattlefieldState"
@onready var matchState: MatchState = $"../../matchState"
@export var map_ground_layer: TileMapLayer
@export var terrain_cards: TerrainCards
@export var map_feature_layer: TileMapLayer
@export var unit_selection_highlight_layer: TileMapLayer
@export var selected_unit_path_highlight_layer: TileMapLayer
@export var selected_unit_action_highlight_layer: TileMapLayer
@export var hover_path_highlight_layer: TileMapLayer
@export var hover_action_highlight_layer: TileMapLayer
@export var sector_highlight_layer: TileMapLayer
@onready var unit_manager: ClientUnitManager = $"../../UnitManager"

var active_came_from: Dictionary = {}
var active_reachable: Dictionary = {}
var _selected_hex: Vector2i = Vector2i(INT32_MAX, INT32_MAX)
var selected_unit: Unit = null
var _hovered_hex: Vector2i = Vector2i(INT32_MAX, INT32_MAX)
var _hovered_unit: Unit = null

var states: Dictionary = {}
var current_state: PhaseState = null

func _ready() -> void:
	_initialize_states()
	matchState.phase_changed.connect(_on_phase_changed)
	_transition_to_phase(matchState.phase)

func _unhandled_input(event: InputEvent) -> void:
	if !current_state:
		return
	if event is InputEventMouseButton and event.pressed:
		var click_position: Vector2 = map_ground_layer.get_global_mouse_position()
		var hex: Vector2i = map_ground_layer.local_to_map(map_ground_layer.to_local(click_position))
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_state.handle_left_click(hex)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			current_state.handle_right_click(hex)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion()

func _handle_mouse_motion() -> void:
	var mouse_position: Vector2 = map_ground_layer.get_global_mouse_position()
	var current_hovered_hex = map_ground_layer.local_to_map(map_ground_layer.to_local(mouse_position))
	if current_hovered_hex == _hovered_hex:
		return
		
	if terrain_cards:
		terrain_cards.clear_terrain_card()
		
	_hovered_hex = current_hovered_hex
	
	if current_state:
		current_state.handle_mouse_motion(_hovered_hex)
		
	if not battlefieldState.map.get_cell(_hovered_hex):
		_hovered_hex = Vector2i(INT32_MAX, INT32_MAX)
		hover_path_highlight_layer.clear()
		hover_action_highlight_layer.clear()
		return
		
	var unit: Unit = unit_manager.get_unit_at(_hovered_hex)
	if !unit:
		_hovered_unit = null
		hover_path_highlight_layer.clear()
		hover_action_highlight_layer.clear()
		hover_path_highlight_layer.modulate.a = 0.20
		hover_path_highlight_layer.highlight_cell(_hovered_hex)
		if terrain_cards:
			terrain_cards.display_terrain_card(mouse_position)
		return
		
	_hovered_unit = unit
	if selected_unit && selected_unit.uuid == unit.uuid:
		hover_path_highlight_layer.clear()
		return
		
	hover_path_highlight_layer.modulate.a = 0.50
	highlight_hovered_unit_reachable_hexes(_hovered_unit)
	highlight_hovered_unit_enemies_within_range_and_los(_hovered_unit)

func _on_card_hovered(card_target: enums.MapSector) -> void:
	var hexes_to_highlight: Array[Vector2i] = []
	for sector_key: enums.MapSector in battlefieldState.sector_index:
		if (sector_key & card_target) != 0:
			var coords_in_sector: Array = battlefieldState.sector_index[sector_key]
			for pos: Vector2i in coords_in_sector:
				hexes_to_highlight.append(pos)
	apply_sector_highlights(hexes_to_highlight)

func apply_sector_highlights(hexes: Array[Vector2i]) -> void:
	for hex in hexes:
		sector_highlight_layer.set_cell(hex, 0, Vector2i(0, 0))

func _on_card_unhovered() -> void:
	sector_highlight_layer.clear()

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

func select_unit(unit: Unit) -> void:
	if !unit:
		return
	selected_unit = unit
	var unit_stats: UnitStats = UnitDatabase.get_stats(selected_unit.type)
	var path_data = BoardPathfinding.get_reachable_hexes(unit_stats.type, unit.hex_coord, battlefieldState.map, unit_manager.get_occupied_coords())
	active_came_from = path_data.get("came_from", {})
	active_reachable = path_data.get("costs", {})

func clear_selection() -> void:
	selected_unit = null
	_selected_hex = Vector2i(INT32_MAX, INT32_MAX)
	active_came_from.clear()
	active_reachable.clear()
	selected_unit_path_highlight_layer.clear()
	selected_unit_action_highlight_layer.clear()

func highlight_selected_unit_reachable_hexes(unit: Unit) -> void:
	selected_unit_path_highlight_layer.clear()
	for coord in active_reachable.keys():
		selected_unit_path_highlight_layer.highlight_cell(coord)

func highlight_hovered_unit_reachable_hexes(unit: Unit) -> void:
	var unit_stats: UnitStats = UnitDatabase.get_stats(unit.type)
	var path_data = BoardPathfinding.get_reachable_hexes(unit_stats.type, unit.hex_coord, battlefieldState.map, unit_manager.get_occupied_coords())
	var came_from: Dictionary = path_data.get("came_from", {})
	hover_path_highlight_layer.clear()
	var reachable_costs: Dictionary = path_data.get("costs", {})
	for coord in reachable_costs.keys():
		hover_path_highlight_layer.highlight_cell(coord)

func highlight_selected_unit_enemies_within_range_and_los(unit: Unit) -> void:
	selected_unit_action_highlight_layer.clear()
	for enemy_hex in unit_manager.get_enemies_within_range_and_los(unit).values():
		selected_unit_action_highlight_layer.highlight_cell(enemy_hex)

func highlight_hovered_unit_enemies_within_range_and_los(unit: Unit) -> void:
	hover_action_highlight_layer.clear()
	for enemy_hex in unit_manager.get_enemies_within_range_and_los(unit).values():
		hover_action_highlight_layer.highlight_cell(enemy_hex)

func clear_all_highlights() -> void:
	unit_selection_highlight_layer.clear()
	selected_unit_path_highlight_layer.clear()
	selected_unit_action_highlight_layer.clear()
	hover_path_highlight_layer.clear()
	hover_action_highlight_layer.clear()
	sector_highlight_layer.clear()

func _initialize_states() -> void:
	var state_container := Node.new()
	state_container.name = "States"
	add_child(state_container)
	var play_card_state := PhaseStatePlayCard.new()
	
	var spawn_units_state := PhaseStateWait.new()
	var draw_hand_state := PhaseStateWait.new()
	var select_state := PhaseStateSelect.new()
	var move_state := PhaseStateMove.new()
	var attack_state := PhaseStateAttack.new()
	
	states[enums.TurnPhase.SPAWN_UNITS] = spawn_units_state
	states[enums.TurnPhase.DRAW_HAND] = draw_hand_state
	states[enums.TurnPhase.PLAY_CARD] = play_card_state
	states[enums.TurnPhase.SELECT] = select_state
	states[enums.TurnPhase.MOVE] = move_state
	states[enums.TurnPhase.ATTACK] = attack_state
	
	for state_key: int in states.keys():
		var state: PhaseState = states[state_key]
		state.name = enums.TurnPhase.find_key(state_key)
		state_container.add_child(state)
		state.setup(self)

func _on_phase_changed(new_phase: enums.TurnPhase) -> void:
	print("Phase changed to: ", enums.TurnPhase.find_key(new_phase))
	_transition_to_phase(new_phase)

func _transition_to_phase(new_phase: enums.TurnPhase) -> void:
	print("Transitioning to phase: ", enums.TurnPhase.find_key(new_phase))
	if states.is_empty():
		return
	if current_state:
		current_state.exit()
	if states.has(new_phase):
		current_state = states[new_phase]
	else:
		current_state = PhaseState.new()
		current_state.setup(self)
	current_state.enter()
