extends MarginContainer
class_name TerrainCards

@onready var battlefieldState: BattlefieldState = $"../../../BattlefieldState"
@onready var ui_control: Control = $"../Debug/ResizeUI/Control"
@export var card_ui_scene: PackedScene
@export var map_ground_layer: TileMapLayer
var _current_terrain_card: TerrainCardUI = null

func _ready() -> void:
	size = Vector2(HandUI.card_size.y, HandUI.card_size.x)

func restore_size() ->void:
	ui_control.restore()

func display_terrain_card(hex: Vector2) -> void:
	var hex_cell = battlefieldState.map.get_cell(hex)
	clear_terrain_card()

	var new_card = card_ui_scene.instantiate()

	var local_hex_pos: Vector2 = map_ground_layer.map_to_local(hex)
	new_card.global_position = Vector2(0.0, 0.0)
	if new_card == null:
		print("TerrainCards: Failed to instantiate card_ui_scene")
		return

	if not new_card is TerrainCardUI:
		print("TerrainCards: card_ui_scene root is not TerrainCardUI. Got: " + str(new_card.get_class()))
		new_card.queue_free()
		return

	var terrain_card_ui := new_card as TerrainCardUI
	terrain_card_ui.name = "TerrainCard_" + str(hex)
	terrain_card_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(terrain_card_ui)
	_current_terrain_card = terrain_card_ui

	var terrain_id: int = hex_cell.ground + enums.CARD_ID_OFFSET

	if terrain_id in enums.TerrainCardId.values():
		#new_card.setup_terrain_visuals(0, str(feature_id))
		new_card.setup_visuals("002")

	new_card.global_position = Vector2.ZERO
	new_card.size = Vector2(HandUI.card_size.y, HandUI.card_size.x)
	new_card.scale = Vector2.ONE

	# Resize the TextureRect
	ui_control.resize()

func clear_terrain_card() -> void:
	if is_instance_valid(_current_terrain_card):
		_current_terrain_card.queue_free()
		_current_terrain_card = null
