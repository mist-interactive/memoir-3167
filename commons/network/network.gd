extends Node
@export var Match: MatchNetwork

signal join_queue_requested(peer_id: int)

var UNIT_SCENE = preload("res://commons/units/Unit.tscn")

@rpc("any_peer","call_remote")
func join_queue() -> void:
	print("calling to server")
	join_queue_requested.emit(multiplayer.get_remote_sender_id())

# usva
signal hex_selected(peer_id: int, hex: Vector2i)
signal hex_broadcast(peer_id: int, hex: Vector2i)

@rpc("any_peer", "call_remote", "reliable")
func request_hex_selection(hex: Vector2i) -> void:
	# runs on server
	if !multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	spawn_unit_on_server(sender, hex, "test")
	hex_selected.emit(sender, hex)

	# fan out to everyone
	sync_hex_selection.rpc(sender, hex)

@rpc("authority", "call_local", "reliable")
func sync_hex_selection(peer_id: int, hex: Vector2i) -> void:
	# runs on all peers
	hex_broadcast.emit(peer_id, hex)


# Antti
func spawn_unit_on_server(peer_id: int, start_coord: Vector2i, unit_type: String) -> void:
	if not multiplayer.is_server():
		return
	var unique_id: String = unit_type + "-" + str(peer_id) + "-" + str(Time.get_ticks_usec())
	var new_unit_data = UnitData.new(unique_id, start_coord, unit_type)
	UnitManager.add_unit(new_unit_data, start_coord)
	var unit := UnitManager.get_unit_at(start_coord) as UnitData
	if unit:
		print(unit.type)
	sync_spawn_unit.rpc(unique_id, start_coord, unit_type)

@rpc("authority", "call_remote", "reliable")
func sync_spawn_unit(unique_id: String, coord: Vector2i, unit_type: String) -> void:
	var new_unit_node = UNIT_SCENE.instantiate()
	new_unit_node.name = unique_id
	new_unit_node.uuid = unique_id
	new_unit_node.hex_coord = coord
	get_tree().current_scene.add_child(new_unit_node)
	UnitManager.add_unit(new_unit_node, coord)
	
