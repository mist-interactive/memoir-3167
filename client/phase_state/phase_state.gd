class_name PhaseState
extends Node

var controller : PlayerController

func setup(player_controller: PlayerController) -> void:
	controller = player_controller

## Called when the server transitions the client INTO this phase.
func enter() -> void:
	pass

## Called when the server transitions the client OUT of this phase.
func exit() -> void:
	pass

## Triggered by PlayerController on left click.
func handle_left_click(hex: Vector2i) -> void:
	var cell_source_id: int = controller.map_ground_layer.get_cell_source_id(hex)
	if cell_source_id == -1:
		controller.clear_selection()
		return
	var unit: Unit = controller.unit_manager.get_unit_at(hex)
	if unit:
		controller.hover_path_highlight_layer.clear()
		controller.hover_action_highlight_layer.clear()
		controller.set_selected_unit(unit)
		controller.highlight_selected_unit_reachable_hexes(unit)
		controller.highlight_selected_unit_enemies_within_range_and_los(unit)
	else:
		controller.clear_selection()
	
## Triggered by PlayerController on right click.
func handle_right_click(hex: Vector2i) -> void:
	controller.clear_selection()

## Triggered by PlayerController when the mouse moves to a new hex.
func handle_mouse_motion(hex: Vector2i) -> void:
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	var unit: Unit = controller.unit_manager.get_unit_at(hex)
	if unit:
		if !controller.selected_unit || controller.selected_unit.hex_coord != hex:
			controller.hover_path_highlight_layer.modulate.a = 0.50
			controller.hover_path_highlight_layer.highlight_cell(hex)
			controller.highlight_hovered_unit_reachable_hexes(unit)
			controller.highlight_hovered_unit_enemies_within_range_and_los(unit)
	else:
		controller.hover_path_highlight_layer.modulate.a = 0.20
		controller.hover_path_highlight_layer.highlight_cell(hex)
	pass
