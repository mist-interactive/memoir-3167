extends HexagonTileMapLayer

@export var highlight_layer: TileMapLayer

@rpc
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			# var click_position: Vector2 = event.global_position
			var click_position: Vector2 = get_global_mouse_position()
			var local_pos := to_local(click_position)
			var hex_coordinate: Vector2i = local_to_map(local_pos)
			print("Player clicked at coord\t: ", click_position)
			print("Screen click at hex\t: ", hex_coordinate)
			highlight_hex(hex_coordinate)
			# Send the coordinate to the server
			# request_hex_selection.rpc(hex_coord)

@rpc
func highlight_hex(hex_coord: Vector2i) -> void:
	highlight_layer.clear()
	highlight_layer.set_cell(hex_coord, 0, Vector2i(0, 0))
