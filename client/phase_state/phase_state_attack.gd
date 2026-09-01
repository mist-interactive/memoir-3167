class_name PhaseStateAttack
extends PhaseState

func handle_left_click(hex: Vector2i) -> void:
	super.handle_left_click(hex)
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
		print("No unit selected")
		return
	var is_my_unit: bool = selected_unit.owner_id == controller.matchState.mySide
	if !is_my_unit:
		print("Not my unit selected")
		return
	var target_unit: Unit = controller.unit_manager.get_unit_at(hex)
	if target_unit and target_unit.owner_id != controller.matchState.mySide:
		print("trying to pew pew")
		if controller.unit_manager.get_enemies_within_range_and_los(selected_unit).has(target_unit.uuid):
			print("actual pew pew")
			Network.Actions.attack_unit.rpc_id(1, controller.unit_manager.selected_unit_id, target_unit.uuid)
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
	if !controller.selected_unit || controller.selected_unit.hex_coord != hex:
		if controller.unit_manager.selected_units_ids.has(unit.uuid):
			controller.hover_path_highlight_layer.modulate.a = 0.20
		else:
			controller.hover_path_highlight_layer.modulate.a = 0.50
		controller.highlight_hovered_unit_enemies_within_range_and_los(unit)
		controller.highlight_hovered_unit_reachable_hexes(unit)
