extends Node
class_name ActionsNetwork

signal draw_hand_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func draw_hand() -> void:
	if !multiplayer.is_server():
		return
	draw_hand_requested.emit(multiplayer.get_remote_sender_id())

signal play_card_requested(peer_id: int, instance_id: int)
@rpc("any_peer", "call_remote")
func play_card(instance_id: int) -> void:
	play_card_requested.emit(multiplayer.get_remote_sender_id(), instance_id)

signal move_unit_requested(peer_id: int, 	unit_id: int, destination: Vector2i)
@rpc("any_peer", "call_remote")
func move_unit(unit_id: int, destination: Vector2i) -> void:
	if !multiplayer.is_server():
		return
	move_unit_requested.emit(multiplayer.get_remote_sender_id(), unit_id, destination)

signal select_unit_requested(peer_id: int, unit_id: int)
@rpc("any_peer", "call_remote")
func select_unit(unit_id: int) -> void:
	if !multiplayer.is_server():
		return
	select_unit_requested.emit(multiplayer.get_remote_sender_id(), unit_id)

signal attack_unit_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func attack_unit() -> void:
	pass

signal draw_card_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func draw_card() ->void:
	if !multiplayer.is_server():
		return
	draw_card_requested.emit(multiplayer.get_remote_sender_id())
