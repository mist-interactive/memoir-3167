extends HexagonTileMapLayer

@export var highlight_layer: TileMapLayer
var player_hex := {}

func _ready() -> void:
	assert(highlight_layer)
	assert(Network)
	Network.hex_broadcast.connect(_on_hex_broadcast)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hex: Vector2i = local_to_map(to_local(get_global_mouse_position()))
		print(hex)
		Network.request_hex_selection.rpc_id(1, hex)

func _on_hex_broadcast(peer_id: int, hex: Vector2i) -> void:
	player_hex[peer_id] = hex
	highlight_layer.clear()
	for id in player_hex.keys():
		highlight_layer.set_cell(player_hex[id], 0, Vector2i(0, 0))
