extends Node

@onready var battlefieldState: BattlefieldState = $"../../BattlefieldState"
@export var map_ground_layer: TileMapLayer
@export var map_feature_layer: TileMapLayer
@export var map_highlight_layer: TileMapLayer
@export var sector_highlight_layer: TileMapLayer
@export var unit_container: Node

var selected_unit_uuid: int = -1
var is_my_turn: bool = false

func _unhandled_input(event: InputEvent) -> void:
	#if not is_my_turn:
		#return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()

func _handle_left_click() -> void:
	var click_position: Vector2 = map_ground_layer.get_global_mouse_position()
	var hex: Vector2i = map_ground_layer.local_to_map(map_ground_layer.to_local(click_position))
	# Check if selected hex is actually on the gameboard
	var cell_source_id := map_ground_layer.get_cell_source_id(hex)
	if cell_source_id != -1:
		Network.Match.request_hex_selection.rpc_id(1, hex)
	
func _on_card_hovered(card_target: enums.MapSector) -> void:
	var hexes_to_highlight: Array[Vector2i] = []
	for sector_key: enums.MapSector in battlefieldState.sector_index:
		if (sector_key & card_target) != 0:
			var coords_in_sector: Array = battlefieldState.sector_index[sector_key]
			for pos: Vector2i in coords_in_sector:
				hexes_to_highlight.append(pos)
	_apply_sector_highlights(hexes_to_highlight)

func _apply_sector_highlights(hexes: Array[Vector2i]) -> void:
	for hex in hexes:
		sector_highlight_layer.set_cell(hex, 0, Vector2i(0, 0))

func _on_card_unhovered() -> void:
	sector_highlight_layer.clear()
