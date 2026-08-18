extends UnitManager
class_name ServerUnitManager
@onready var matchState: MatchState = $"../matchState"
var _unit_id_counter: int = 0
var isDirty: bool = true

func _init(initialState: BattlefieldState) -> void:
	super(initialState)

func _sync_units(sides_peer_ids: Dictionary[enums.Side, int]) -> void:
	for uuid in units_by_id:
		var unit: UnitData = units_by_id[uuid]
		unit.sync(sides_peer_ids.values())
	if isDirty:
		for peer_id in sides_peer_ids.values():
			var snapshot: Dictionary = {
				"selected_unit_id": selected_unit_id,
				"selected_by_peer": selected_by_peer, 
				}
			Network.Units.sync_all.rpc_id(peer_id, snapshot)
		isDirty = false

func select_unit(owner: enums.Side, unit_id: int) -> bool:
	var unit: UnitData = get_unit_by_id(unit_id)
	
	if unit == null:
		return false

	if unit.owner_id != owner:
		return false

	if selected_unit_id != -1:
		return false
	
	selected_unit_id = unit_id
	selected_by_peer = owner
	
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
	
func move_unit_request( owner: enums.Side, unit_id: int, destination: Vector2i) -> bool:
	var unit: UnitData = get_unit_by_id(unit_id)
	if unit == null || unit.owner_id != owner:
		return false
	
	if selected_unit_id != unit_id || selected_by_peer != owner:
		return false

	## Check movement rules.
	#if !move_rules(unit, destination):
		#return false

	var old_coord := unit.hex_coord
	if !move_unit(unit, old_coord, destination):
		return false

	selected_unit_id = -1
	selected_by_peer = -1
	isDirty = true
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
		var unit: UnitData = UnitData.new(enums.Side.GREEN, elem.type, generate_server_unit_id(),coord)
		add_unit(unit, coord)
		elem.owner_id = unit.owner_id
		#elem.owner_id = 1
		elem.uuid = unit.uuid
		var new_unit: Dictionary = {
			"owner_id": elem.owner_id,
			"uuid": elem.uuid,
			"type": elem.type,
			"coord": coord
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
			"coord": coord
		}
		for peer_id in sides_peer_ids.values():
			Network.Units.spawn_unit.rpc_id(peer_id, new_unit)
