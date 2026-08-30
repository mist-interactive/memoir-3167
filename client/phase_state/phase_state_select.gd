class_name PhaseStateSelect
extends PhaseState

func handle_left_click(hex: Vector2i) -> void:
	super.handle_left_click(hex)
	if controller.matchState.is_my_turn():
		var selected_unit: Unit = controller.selected_unit
		if not selected_unit:
			return
		var is_my_unit: bool = selected_unit.owner_id == controller.matchState.mySide
		if is_my_unit:
			if not controller.unit_manager.selected_units_ids.has(selected_unit.uuid):
				Network.Actions.select_unit.rpc_id(1, controller.unit_manager.get_unit_at(hex).uuid)
			else:
				#NOTE: Add unit deselection here
				print("Deselect unit (not functional yet)!")
