extends Control

@export var terrain_card_ui: TerrainCardUI

func resize() -> void:
	pass
func restore() -> void:
	terrain_card_ui.hide_elements()
