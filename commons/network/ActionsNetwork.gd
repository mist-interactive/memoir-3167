extends Node
class_name ActionsNetwork

signal hand_drawn_requested
@rpc("authority", "call_remote")
func  hand_drawn() -> void:
	if multiplayer.is_server():
		return
	hand_drawn_requested.emit()

signal play_card_requested(peer_id: int, card_id: String)
@rpc("any_peer", "call_remote")
func play_card(card_id: String) -> void:
	play_card_requested.emit(multiplayer.get_remote_sender_id(), card_id)

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
