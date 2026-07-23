extends Node
class_name CardNetwork

var active_hand_model: PlayerHandModel = null

signal local_card_received(instance_id: int, card_id: String)
signal local_card_removed(instance_id: int)
signal play_card_requested(peer_id: int, instance_id: int)

@rpc("authority", "call_remote", "reliable")
func receive_card_from_server(instance_id: int, card_id: String) -> void:
	print("Network: Packet received for instance %d, card: %s" % [instance_id, card_id])
	active_hand_model.add_card(instance_id, card_id)

@rpc("authority", "reliable")
func confirm_card_played(instance_id: int) -> void:
	active_hand_model.remove_card(instance_id)

func request_card_play(instance_id: int) -> void:
	request_play_card.rpc(instance_id)

@rpc("any_peer", "reliable")
func request_play_card(instance_id: int) -> void:
	pass
