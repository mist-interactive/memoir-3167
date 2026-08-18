extends HexagonTileMapLayer
@onready var matchState: MatchState = $"../../../matchState"

var player_hex := {}

func _ready() -> void:
	Network.Match.hex_broadcast.connect(_on_hex_broadcast)
	Network.Match.clear_hex_selections_requested.connect(_on_clear_hex_selections)

func _on_hex_broadcast(side: enums.Side, hex: Vector2i) -> void:
	if side == matchState.mySide:
		clear()
		set_cell(hex, 0, Vector2i(0, 0))
	#else:
	#	return
	clear()
	# Highlights both players' selections
	player_hex[side] = hex
	for id in player_hex.keys():
		set_cell(player_hex[id], 0, Vector2i(0, 0))

func _on_clear_hex_selections() -> void:
	clear()
	player_hex.clear()
