extends UnitManager
class_name ServerUnitManager
var _unit_id_counter: int = 0

func _init(initialState: BattlefieldState) -> void:
	super(initialState)

func _physics_process(delta: float) -> void:
	for uuid in units_by_id:
		var unit: UnitData = units_by_id[uuid]
		unit.sync()
		unit.hex_coord = Vector2i(1,2)
	
func generate_server_unit_id() -> int:
	if not multiplayer.is_server():
		push_error("Client tried to generate a unit ID.")
		return -1
	_unit_id_counter += 1
	return _unit_id_counter

func spawn_units(peer_id1: int, peer_id2: int) -> void:
	#tmp client1 --> owner_id=1, client2 --> owner_id=2
	for elem in battlefield.units_to_spawn_player_1:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(peer_id1, elem.type, generate_server_unit_id(),coord)
		add_unit(unit, coord)
		elem.owner_id = unit.owner_id
		elem.uuid = unit.uuid
		Network.Units.spawn_unit.rpc_id(peer_id1, elem)
		Network.Units.spawn_unit.rpc_id(peer_id2, elem)

	for elem in battlefield.units_to_spawn_player_2:
		var coord: Vector2i = Vector2i(elem.coord[0], elem.coord[1])
		var unit: UnitData = UnitData.new(peer_id2, elem.type, generate_server_unit_id(), coord)
		add_unit(unit, coord)
		elem.owner_id = unit.owner_id
		elem.uuid = unit.uuid
		Network.Units.spawn_unit.rpc_id(peer_id1, elem)
		Network.Units.spawn_unit.rpc_id(peer_id2, elem)
