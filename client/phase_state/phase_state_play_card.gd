class_name PhaseStatePlayCard
extends PhaseState

## Called when the server transitions the client INTO this phase.
func enter() -> void:
	#controller.clear_all_highlights()
	controller.unit_selection_highlight_layer.clear()
	controller.selected_unit_path_highlight_layer.clear()
	controller.selected_unit_action_highlight_layer.clear()
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	controller.sector_highlight_layer.clear()
	pass

## Called when the server transitions the client OUT of this phase.
func exit() -> void:
	#controller.clear_all_highlights()
	controller.unit_selection_highlight_layer.clear()
	controller.selected_unit_path_highlight_layer.clear()
	controller.selected_unit_action_highlight_layer.clear()
	controller.hover_path_highlight_layer.clear()
	controller.hover_action_highlight_layer.clear()
	controller.sector_highlight_layer.clear()
	pass
