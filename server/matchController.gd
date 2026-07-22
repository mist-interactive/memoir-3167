extends Node
class_name  MatchController
var matchState: MatchState
var battlefield: BattlefieldState
var unit_manager: UnitManager
var connected: Dictionary[int, bool]

var UNIT_SCENE = preload("res://commons/units/Unit.tscn")

func _init(matchState: MatchState, battlefield: BattlefieldState) -> void:
	self.matchState = matchState
	self.battlefield = battlefield

func handle_connect(player_id: int) -> void:
	self.connected[player_id] = true
	Network.Match.init.rpc_id(player_id, matchState.matchId, battlefield.mapName, matchState.player_ids)

func handle_disconnect(player_id: int) -> void:
	self.connected[player_id] = false

# Antti
func spawn_unit_on_server(owner_id: int, unit_type: String, start_coord: Vector2i) -> void:
	if not multiplayer.is_server():
		return
	var unique_id: String = unit_type + "-" + str(owner_id) + "-" + str(Time.get_ticks_usec())
	var new_unit_data = UnitData.new(owner_id, unit_type, unique_id, start_coord)
	unit_manager.add_unit(new_unit_data, start_coord)
	var unit := unit_manager.get_unit_at(start_coord) as UnitData
	for peer in matchState.player_ids:
		sync_spawn_unit.rpc_id(peer, owner_id, unit_type, unique_id, start_coord)

@rpc("authority", "call_remote", "reliable")
func sync_spawn_unit(owner_id: int, unit_type: String, unique_id: String, coord: Vector2i) -> void:
	var new_unit_node = UNIT_SCENE.instantiate()
	new_unit_node.name = unique_id
	new_unit_node.uuid = unique_id
	new_unit_node.type = unit_type
	new_unit_node.hex_coord = coord
	new_unit_node.owner_id = owner_id
	get_tree().current_scene.add_child(new_unit_node)
	unit_manager.add_unit(new_unit_node, coord)
