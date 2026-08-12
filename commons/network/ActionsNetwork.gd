extends Node
class_name ActionsNetwork

signal hand_drawn_requested
@rpc("authority", "call_remote")
func  hand_drawn() -> void:
	if multiplayer.is_server():
		return
	hand_drawn_requested.emit()

signal play_card_requested(peer_id: int, instance_id: int)
@rpc("any_peer", "call_remote")
func play_card(instance_id: int) -> void:
	play_card_requested.emit(multiplayer.get_remote_sender_id(), instance_id)

signal card_played_received(peer_id: int, instance_id: int, card_id: String)
@rpc("authority", "call_remote")
func card_played(peer_id: int, instance_id: int, card_id: String) -> void:
	if multiplayer.is_server():
		return
	print("I played the card ", peer_id == multiplayer.get_unique_id())
	card_played_received.emit(peer_id, instance_id, card_id)

signal issue_order_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func issue_order() ->void:
	pass
	
signal execute_orders_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func execute_orders() ->void:
	pass

signal draw_card_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func draw_card() ->void:
	if !multiplayer.is_server():
		return
	draw_card_requested.emit(multiplayer.get_remote_sender_id())

signal enemy_hand_size_changed(new_size: int)
@rpc("authority", "call_remote", "reliable")
func receive_enemy_hand_update(new_size: int) -> void:
	enemy_hand_size_changed.emit(new_size)
