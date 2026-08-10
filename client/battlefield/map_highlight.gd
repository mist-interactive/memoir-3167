extends HexagonTileMapLayer

var player_hex := {}

func _ready() -> void:
	Network.Match.hex_broadcast.connect(_on_hex_broadcast)

func _on_hex_broadcast(peer_id: int, hex: Vector2i) -> void:
	if peer_id == multiplayer.get_unique_id():
		clear()
		set_cell(hex, 0, Vector2i(0, 0))
	#else:
	#	return
	clear()
	# Highlights both players' selections
	player_hex[peer_id] = hex
	for id in player_hex.keys():
		set_cell(player_hex[id], 0, Vector2i(0, 0))
