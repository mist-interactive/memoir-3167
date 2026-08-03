# battlefield.gd (Attached to the root Node2D of battlefield.tscn)
extends Node2D

@onready var map_manager: ClientMapManager = $MapManager # Update path if needed

func setup_hand_ui(player_ids: Array[int]) -> void:
	# Delegate the responsibility to the child that actually manages the UI/Map
	if map_manager:
		map_manager.setup_hand_ui(player_ids)
	else:
		push_error("Battlefield root could not find ClientMapManager.")
