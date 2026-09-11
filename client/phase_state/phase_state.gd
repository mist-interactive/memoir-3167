class_name PhaseState
extends Node

var controller : PlayerController

func setup(player_controller: PlayerController) -> void:
	controller = player_controller

## Called when the server transitions the client INTO this phase.
func enter() -> void:
	controller.unit_selection_highlight_layer.clear()
	controller.selected_unit_path_highlight_layer.clear()
	controller.selected_unit_action_highlight_layer.clear()
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	controller.sector_highlight_layer.clear()

## Called when the server transitions the client OUT of this phase.
func exit() -> void:
	controller.unit_selection_highlight_layer.clear()
	controller.selected_unit_path_highlight_layer.clear()
	controller.selected_unit_action_highlight_layer.clear()
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	controller.sector_highlight_layer.clear()

func handle_left_click(hex: Vector2i) -> void:
	var cell_source_id: int = controller.map_ground_layer.get_cell_source_id(hex)
	if cell_source_id == -1:
		controller.clear_selection()
		return
	var unit: Unit = controller.unit_manager.get_unit_at(hex)
	if unit:
		controller.hover_path_highlight_layer.clear()
		controller.hover_action_highlight_layer.clear()
		controller.select_unit(unit)
		controller.highlight_selected_unit_reachable_hexes(unit)
		controller.highlight_selected_unit_enemies_within_range_and_los(unit)
	else:
		controller.clear_selection()
	
func handle_right_click(hex: Vector2i) -> void:
	controller.clear_selection()

func handle_mouse_motion(hex: Vector2i) -> void:
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	if not controller.battlefieldState.map.cells.has(hex):
		return
	controller.terrain_cards.display_terrain_card(hex)
	var unit: Unit = controller.unit_manager.get_unit_at(hex)
	if not unit:
		controller.hover_path_highlight_layer.modulate.a = 0.20
		controller.hover_path_highlight_layer.highlight_cell(hex)
		return
	else:
		if !controller.selected_unit || controller.selected_unit.hex_coord != hex:
			controller.hover_path_highlight_layer.modulate.a = 0.50
			controller.hover_path_highlight_layer.highlight_cell(hex)
			controller.highlight_hovered_unit_reachable_hexes(unit)
			controller.highlight_hovered_unit_enemies_within_range_and_los(unit)
