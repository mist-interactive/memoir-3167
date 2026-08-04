extends HexagonTileMapLayer

@export var highlight_layer: TileMapLayer
var player_hex := {}

func _ready() -> void:
	assert(highlight_layer)
	assert(Network)
	Network.Match.hex_broadcast.connect(_on_hex_broadcast)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position: Vector2 = get_global_mouse_position()
		var math_pos: Vector2 = click_position - Vector2(HexMetrics.half_width, HexMetrics.half_height)
		var hex: Vector2i = HexGrid.pixel_to_offset(math_pos, HexMetrics.HEX_SIZE)
		Network.Match.request_hex_selection.rpc_id(1, hex)

func _on_hex_broadcast(peer_id: int, hex: Vector2i) -> void:
	if peer_id == multiplayer.get_unique_id():
		highlight_layer.clear()
		highlight_layer.set_cell(hex, 0, Vector2i(0, 0))
	#else:
	#	return
	highlight_layer.clear()
	# Highlights both players' selections
	player_hex[peer_id] = hex
	for id in player_hex.keys():
		highlight_layer.set_cell(player_hex[id], 0, Vector2i(0, 0))
