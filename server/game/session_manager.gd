class_name SessionManager
extends Node
var player_sessions: Dictionary[int, PlayerSession]

func _ready() -> void:
	name = "SessionManager"

func register_new_session(uuid: int, peer_id: int) -> void:
	var session: PlayerSession
	if !player_sessions.has(uuid):
		session = PlayerSession.new()
		player_sessions[uuid] = session
	else:
		session = player_sessions[uuid]
	session.peer_id = peer_id
	session.set_status(enums.ConnectionStatus.Connected)

func client_is_ready(uuid: int) -> void:
	player_sessions[uuid].set_status(enums.ConnectionStatus.Ready)

func client_disconnected(uuid: int) -> void:
	player_sessions[uuid].set_status(enums.ConnectionStatus.Disconnected)

func client_is_playing(uuid: int) -> void:
	player_sessions[uuid].set_status(enums.ConnectionStatus.Playing)

func players_are_ready(player_count: int = 2) -> bool:
	for session: PlayerSession in player_sessions.values():
		if !session.is_status_set(enums.ConnectionStatus.Ready):
			return false
	return true

func players_are_connected(player_count: int = 2) -> bool:
	if player_sessions.size() != player_count:
		return false
	for session: PlayerSession in player_sessions.values():
		if !session.is_status_set(enums.ConnectionStatus.Connected):
			return false
	return true

func get_peer_ids() -> Array[int]:
	var peer_ids: Array[int]
	for session: PlayerSession in player_sessions.values():
		peer_ids.append(session.peer_id)
	return peer_ids

func get_uuids() -> Array[int]:
	return player_sessions.keys()

func get_sides_peer_ids(sides_uuid: Dictionary[enums.Side, int]) -> Dictionary[enums.Side, int]:
	return {
		enums.Side.GREEN: player_sessions[sides_uuid[enums.Side.GREEN]].peer_id if sides_uuid.has(enums.Side.GREEN) else -1,
		enums.Side.RED: player_sessions[sides_uuid[enums.Side.RED]].peer_id if sides_uuid.has(enums.Side.RED) else -1
		}
func get_sessions() -> Dictionary[int, PlayerSession]:
	return player_sessions
