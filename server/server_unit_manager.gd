extends UnitManager
class_name ServerUnitManager
@onready var matchState: MatchState = $"../matchState"
var _unit_id_counter: int = 0
var isDirty: bool = true

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

func select_unit(owner: enums.Side, unit_id: int) -> bool:
	var unit: UnitData = get_unit_by_id(unit_id)
	
	if unit == null:
		return false

	if unit.owner_id != owner:
		return false
	
	selected_unit_id = unit_id
	selected_by_peer = owner
	if !selected_units_ids.has(unit_id):
		selected_units_ids.append(unit_id)
	isDirty = true
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

	## Check movement rules.
	#if !move_rules(unit, destination):
		#return false
	
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
	return true

func generate_server_unit_id() -> int:
	if not multiplayer.is_server():
		push_error("Client tried to generate a unit ID.")
		return -1
	_unit_id_counter += 1
	return _unit_id_counter

func spawn_units(sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	#tmp GREEN_SIDE --> owner_id=1, RED_SIDE --> owner_id=2
	
	for elem in battlefield.units_to_spawn_player_1:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(enums.Side.GREEN, elem.type,generate_server_unit_id(), coord)
		add_unit(unit, coord)
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

	for elem in battlefield.units_to_spawn_player_2:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(enums.Side.RED, elem.type, generate_server_unit_id(), coord)
		add_unit(unit, coord)
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

func resolve_combat(result: CombatResult) -> void:
	var target_id: int = result.unit_ids[result.target]
	var target: UnitData = units_by_id[target_id]
	var should_retreat: int = 0
	for rolled_dice in result.rolled_dices:
		if target.type == rolled_dice || rolled_dice == enums.RolledDice.ALL:
			result.dmg += 1
		elif rolled_dice == enums.RolledDice.ARMOR && (target.type == enums.UnitType.TANK || target.type == enums.UnitType.ARTILLERY):
			result.dmg += 1
		elif rolled_dice == enums.RolledDice.RETREAT:
			result.retreat += 1
	if should_retreat:
		pass #retreat to prev pos
	target.hit_point -= result.dmg
