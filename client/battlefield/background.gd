extends Node2D

@export var client_map_manager: ClientMapManager
@export var background_tilemap: TileMapLayer

func _ready() -> void:
	client_map_manager.map_loaded.connect(_on_map_loaded)

func _on_map_loaded() -> void:
	background_tilemap.position = client_map_manager.map_offset
