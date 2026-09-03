extends Node
const Server = preload("res://server/server.tscn")
const Client = preload("res://client/client.tscn")

func _ready() -> void:
	if OS.has_feature("server"):
		get_tree().change_scene_to_packed.call_deferred(Server)
	else:
		get_window().position.x += ceil(get_window().size.x / 2.0 + 4)
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_packed.call_deferred(Client)
