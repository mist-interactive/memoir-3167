class_name PhaseStateMove
extends PhaseState

func handle_left_click(hex: Vector2i) -> void:
	super.handle_left_click(hex)
	if controller.matchState.is_my_turn():
		var selected_unit: Unit = controller.selected_unit
		if not selected_unit:
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
	if not controller.active_came_from.has(hex):
		print("Can't reach hex: ", hex)
		return
	Network.Actions.move_unit.rpc_id(1, controller.unit_manager.selected_unit_id, hex)
	print("moving")
	controller.clear_selection()
