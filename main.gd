extends Node

func _ready() -> void:
	if OS.has_feature("server"):
		get_tree().change_scene_to_file.call_deferred("res://server/server.tscn")
	else:
		get_tree().change_scene_to_file.call_deferred("res://client/client.tscn")
