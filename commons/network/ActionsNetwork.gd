extends Node
class_name ActionsNetwork

signal play_card_requested(peer_id: int)
@rpc("any_peer", "call_remote")
func play_card() -> void:
	pass

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
	pass
