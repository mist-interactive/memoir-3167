extends UnitManager
class_name ServerUnitManager
@onready var matchState: MatchState = $"../matchState"
@onready var battlefieldState: BattlefieldState = $"../BattlefieldState"
@onready var match_controller: matchController = $".."
var _unit_id_counter: int = 0
var isDirty: bool = true
var death_queue: Array[int]
var logger: LogService

func _ready() -> void:
	logger = match_controller.logger.with_context({
		"component": "unitManager"
	})

func _init(initialState: BattlefieldState) -> void:
	super(initialState)

func is_unit_selected(unit_id: int) -> bool:
	return selected_units_ids.has(unit_id)

func has_unit_moved(unit_id: int) -> bool:
	return moved_units_ids.has(unit_id)

func has_unit_attacked(unit_id: int) -> bool:
	return attacked_units_ids.has(unit_id)

func _sync_units(sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	for uuid in units_by_id:
		var unit: UnitData = units_by_id[uuid]
		unit.sync(sides_peer_ids.values())
	if !death_queue.is_empty():
		isDirty = true
		for uuid: int in death_queue:
			for peer_id in sides_peer_ids.values():
				Network.Units.destroy_unit.rpc_id(peer_id, uuid)
			unit_grid.erase(units_by_id[uuid].hex_coord)
			units_by_id.erase(uuid)
		death_queue.clear()
	if isDirty:
		for peer_id in sides_peer_ids.values():
			var snapshot: Dictionary = {
				"selected_unit_id": selected_unit_id,
				"selected_by_peer": selected_by_peer,
				"selected_units_ids" : selected_units_ids,
				"moved_units_ids": moved_units_ids,
				"attacked_units_ids": attacked_units_ids
				}
			Network.Units.sync_all.rpc_id(peer_id, snapshot)
		isDirty = false

func select_unit(owner: enums.Side, unit_id: int, card: CommandCard) -> bool:
	var unit: UnitData = get_unit_by_id(unit_id)

	if unit == null:
		return false

	if unit.owner_id != owner:
		return false
	selected_unit_id = unit_id
	selected_by_peer = owner
	if matchState.phase == enums.TurnPhase.SELECT && !selected_units_ids.has(unit_id):
		selected_units_ids.append(unit_id)
	isDirty = true
	var player_logger := logger.with_context({
		"side": owner
	})
	player_logger.info("Selected unit(%d)" % [unit_id])
	return true

func deselect_unit(owner: enums.Side) -> bool:
	if selected_unit_id == -1:
		return false

	if selected_by_peer != owner:
		return false

	selected_unit_id = -1
	selected_by_peer = -1
	isDirty = true
	return true

func move_unit_request( owner: enums.Side, unit_id: int, destination: Vector2i, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	var unit: UnitData = get_unit_by_id(unit_id)
	
	if unit == null || unit.owner_id != owner:
		return false

	if selected_unit_id != unit_id || selected_by_peer != owner:
		return false

	if !BoardPathfinding.get_reachable_hexes(unit.type, unit.hex_coord, battlefieldState.map, get_occupied_coords())["costs"].has(destination):
		return false

	var unit_path = BoardPathfinding.get_unit_path(unit, unit.hex_coord, destination, battlefield.map, get_occupied_coords())
	var old_coord := unit.hex_coord
	if !move_unit(unit, old_coord, destination):
		return false

	for peer_id in sides_peer_ids.values():
		Network.Actions.sync_unit_path.rpc_id(peer_id, unit_id, unit_path)
	selected_unit_id = -1
	selected_by_peer = enums.Side.NONE
	isDirty = true
	moved_units_ids.append(unit_id)
	var player_logger := logger.with_context({
		"peer_id": sides_peer_ids[owner],
		"side": owner
	})
	player_logger.info("Unit(%d) moved from %v to %v" % [unit_id, old_coord, destination])
	return true

func attack_unit(side: enums.Side, unit_id: int, target_unit_id: int, sides_peer_ids: Dictionary[enums.Side, int]) -> bool:
	if !units_by_id.has(unit_id) || !units_by_id.has(target_unit_id):
		return false
	var unit: UnitData = units_by_id[unit_id]
	var target: UnitData = units_by_id[target_unit_id]
	if !unit.is_my_unit(side) || target.is_my_unit(side):
		return false
	if unit.uuid != selected_unit_id || side != selected_by_peer:
		return false
	var targets: Dictionary[int, Vector2i] = get_enemies_within_range_and_los(unit)
	if !targets.has(target_unit_id):
		return false
	var d: int = battlefield.map.distance(unit.hex_coord, target.hex_coord)
	var num_of_dice: int = UnitDatabase.get_stats(unit.type).attack_dice_by_distance[d - 1]
	var rolled_dices: Array[enums.RolledDice] = Dice.roll(num_of_dice)
	var combat_result: CombatResult = CombatResult.new()
	combat_result.initialize(unit, target, rolled_dices)
	resolve_combat(combat_result)
	for peer_id in sides_peer_ids.values():
		Network.Actions.resolve_combat_result.rpc_id(peer_id, combat_result.to_dict())
	selected_unit_id = -1
	selected_by_peer = enums.Side.NONE
	isDirty = true
	attacked_units_ids.append(unit_id)
	var player_logger := logger.with_context({
		"peer_id": sides_peer_ids[side],
		"side": side
	})
	player_logger.info("Unit(%d) attacked unit(%d)" % [unit_id, target_unit_id])
	player_logger.info("Combat result ", combat_result.to_dict())
	return true

func generate_server_unit_id() -> int:
	_unit_id_counter += 1
	return _unit_id_counter

func spawn_units(sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	#tmp GREEN_SIDE --> owner_id=1, RED_SIDE --> owner_id=2

	for elem in battlefield.units_to_spawn_player_1:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(enums.Side.GREEN, elem.type,generate_server_unit_id(), coord)
		elem.owner_id = unit.owner_id
		elem.uuid = unit.uuid
		var new_unit: Dictionary = {
			"owner_id": elem.owner_id,
			"uuid": elem.uuid,
			"type": elem.type,
			"coord": coord,
			"hit_point": unit.hit_point
		}
		for peer_id in sides_peer_ids.values():
			Network.Units.spawn_unit.rpc_id(peer_id, new_unit)
		add_unit(unit, coord)

	for elem in battlefield.units_to_spawn_player_2:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(enums.Side.RED, elem.type, generate_server_unit_id(), coord)
		elem.owner_id = unit.owner_id
		elem.uuid = unit.uuid
		var new_unit: Dictionary = {
			"owner_id": elem.owner_id,
			"uuid": elem.uuid,
			"type": elem.type,
			"coord": coord,
			"hit_point": unit.hit_point
		}
		for peer_id in sides_peer_ids.values():
			Network.Units.spawn_unit.rpc_id(peer_id, new_unit)
		add_unit(unit, coord)

func resolve_combat(result: CombatResult) -> void:
	var target_id: int = result.unit_ids[result.target]
	var target: UnitData = units_by_id[target_id]
	var should_retreat: int = 0
	for rolled_dice in result.rolled_dices:
		if rolled_dice == enums.RolledDice.ALL:
			result.dmg += 1
		elif rolled_dice == enums.RolledDice.RETREAT:
			result.retreat += 1
		elif target.type == enums.UnitType.INFANTRY && (rolled_dice == enums.RolledDice.INFANTRY_1 || rolled_dice == enums.RolledDice.INFANTRY_2):
			result.dmg += 1
		elif (target.type == enums.UnitType.TANK || target.type == enums.UnitType.ARTILLERY) && rolled_dice == enums.RolledDice.ARMOR:
			result.dmg += 1
	if should_retreat:
		pass #retreat to prev pos
	target.hit_point -= result.dmg
	if target.hit_point <= 0:
		death_queue.append(target_id)

func next_phase(phase: enums.TurnPhase) -> void:
	if phase == enums.TurnPhase.PLAY_CARD:
		selected_units_ids.clear()
		moved_units_ids.clear()
		attacked_units_ids.clear()
	selected_unit_id = -1
	isDirty = true

func can_card_target_unit(card: CommandCard, unit_id: int) -> bool:
	var unit: UnitData = units_by_id[unit_id]
	if card.target_unit != unit.type && card.target_unit != enums.UnitType.ANY:
		return false
	var allowed_sectors := card.get_map_sectors()
	var hex_sectors := battlefield.get_map_sectors_by_hex(unit.hex_coord)
	var is_targetable := false
	for sector in hex_sectors:
		if allowed_sectors.has(sector):
			is_targetable = true
			break
	if not is_targetable:
		return false
	if selected_units_ids.has(unit_id):
		return true
	var trial_ids: Array[int] = selected_units_ids.duplicate()
	trial_ids.append(unit_id)
	return can_assign_all(trial_ids, allowed_sectors, card.target_unit_limit)

func can_assign_all(unit_ids: Array[int], allowed_sectors: Array[enums.MapSector], limit: int) -> bool:
	var sector_occupants: Dictionary = {}  # sector -> Array[int] (unit_ids)
	for s in allowed_sectors:
		sector_occupants[s] = [] as Array[int]
	for uid in unit_ids:
		var visited: Dictionary = {}
		if not try_assign(uid, allowed_sectors, limit, sector_occupants, visited):
			return false
	return true

func try_assign(uid: int, allowed_sectors: Array, limit: int,
		sector_occupants: Dictionary, visited: Dictionary) -> bool:
	var hex: Vector2i = units_by_id[uid].hex_coord
	var sectors: Array[enums.MapSector] = battlefieldState.get_map_sectors_by_hex(hex)
	for sector in sectors:
		if not allowed_sectors.has(sector) or visited.has(sector):
			continue
		visited[sector] = true

		var occupants: Array = sector_occupants[sector]
		if occupants.size() < limit:
			occupants.append(uid)
			return true

		for other_uid in occupants.duplicate():
			occupants.erase(other_uid)
			if try_assign(other_uid, allowed_sectors, limit, sector_occupants, visited):
				occupants.append(uid)
				return true
			occupants.append(other_uid)
	return false
