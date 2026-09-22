extends Control

@export var terrain_card_ui: TerrainCardUI

func restore() -> void:
	terrain_card_ui.hide_elements()
