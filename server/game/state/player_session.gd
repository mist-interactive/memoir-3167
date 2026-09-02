class_name PlayerSession
extends RefCounted

var status_mask: enums.ConnectionStatus = enums.ConnectionStatus.Disconnected
var last_seen: Time
var peer_id: int

func set_status(status: enums.ConnectionStatus) -> void:
	if status == enums.ConnectionStatus.Disconnected:
		status_mask = status
	else:
		status_mask |= status

func remove_status(status: enums.ConnectionStatus) -> void:
	status_mask &= ~status

func is_status_set(status: enums.ConnectionStatus) -> bool:
	return (status_mask & status) != 0
