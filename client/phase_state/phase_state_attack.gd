class_name PhaseStateAttack
extends PhaseState

func handle_left_click(hex: Vector2i) -> void:
	super.handle_left_click(hex)
	controller.selected_unit_path_highlight_layer.clear()
	controller.selected_unit_path_highlight_layer.highlight_cell(hex)
	if controller.matchState.is_my_turn():
		var selected_unit: Unit = controller.selected_unit
		if not selected_unit:
			return
		if controller.unit_manager.selected_units_ids.has(selected_unit.uuid):
			controller.selected_unit_path_highlight_layer.modulate.a = 0.20
		else:
			controller.selected_unit_path_highlight_layer.modulate.a = 0.50
			return
		var is_my_unit: bool = selected_unit.owner_id == controller.matchState.mySide
		if is_my_unit:
			Network.Actions.select_unit.rpc_id(1, controller.unit_manager.get_unit_at(hex).uuid)

func handle_right_click(hex: Vector2i) -> void:
	var selected_unit = controller.selected_unit
	if not selected_unit:
		return
	var is_my_unit: bool = selected_unit.owner_id == controller.matchState.mySide
	if !is_my_unit:
		return
	var target_unit: Unit = controller.unit_manager.get_unit_at(hex)
	if target_unit and target_unit.owner_id != controller.matchState.mySide:
		if controller.unit_manager.get_enemies_within_range_and_los(selected_unit).has(target_unit.uuid):
			Network.Actions.attack_unit.rpc_id(1, controller.unit_manager.selected_unit_id, target_unit.uuid)
			controller.clear_selection()
