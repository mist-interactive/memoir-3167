extends MarginContainer
class_name TerrainCards

@onready var battlefieldState: BattlefieldState = $"../../../BattlefieldState"
@export var card_ui_scene: PackedScene
@export var map_ground_layer: TileMapLayer
var _current_terrain_card: CardUI = null

func _ready() -> void:
	size = Vector2(HandUI.card_size.y, HandUI.card_size.x)

func display_terrain_card(hex: Vector2) -> void:
	var hex_cell = battlefieldState.map.get_cell(hex)
	clear_terrain_card()
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI
	new_card.name = "TerrainCard_" + str(hex)
	new_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(new_card)
	_current_terrain_card = new_card
	var feature_id: int = hex_cell.feature + enums.CARD_ID_OFFSET
	if feature_id in enums.TerrainCardId.values():
		new_card.setup_visuals(0, str(feature_id))
	var local_hex_pos: Vector2 = map_ground_layer.map_to_local(hex)
	new_card.global_position = Vector2(0.0, 0.0)
	new_card.size = Vector2(HandUI.card_size.y, HandUI.card_size.x)
	new_card.scale = Vector2(1.0, 1.0)

func clear_terrain_card() -> void:
	if is_instance_valid(_current_terrain_card):
		_current_terrain_card.queue_free()
		_current_terrain_card = null
