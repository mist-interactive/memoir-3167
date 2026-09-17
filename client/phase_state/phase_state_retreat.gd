class_name PhaseStateRetreat
extends PhaseState

func _process(delta: float) -> void:
	controller.highlight_possible_retreats()

func handle_left_click(hex: Vector2i) -> void:
	pass

func handle_right_click(hex: Vector2i) -> void:
	if !controller.matchState.is_my_turn():
		return
	for unit: Unit in controller.unit_manager.units_by_id.values():
		if unit.num_of_retreat > 0 && unit.hex_coord != hex:
			var side: enums.Side
			if controller.matchState.is_my_turn():
				side = controller.matchState.mySide
			else:
				side = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN
			var tree: BinaryTree = controller.unit_manager.get_retreat_coords(side, unit.hex_coord, unit, unit.num_of_retreat)
			var coords: Array[Variant] = tree.to_array()
			if coords.has(hex):
				Network.Actions.retreat_unit.rpc_id(1, unit.uuid, hex)
			break;
