extends HexagonTileMapLayer

@export var highlight_layer: TileMapLayer
@export var sector_highlight_layer: TileMapLayer
@onready var battlefieldState: BattlefieldState = $"../../BattlefieldState"

var player_hex := {}

func _ready() -> void:
	assert(Network)
	Network.Match.hex_broadcast.connect(_on_hex_broadcast)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position: Vector2 = get_global_mouse_position()
		var hex: Vector2i = local_to_map(to_local(click_position))
		# Check if selected hex is actually on the gameboard
		var cell_source_id := get_cell_source_id(hex)
		if cell_source_id != -1:
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
