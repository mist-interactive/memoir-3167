class_name CardUI
extends MarginContainer

signal card_clicked(instance_id: int)

const SIZE := Vector2(120, 220)

@export var title_label: Label
@export var description_label: Label
@onready var background_texture: TextureRect

var _instance_id: int
var _card_id: String

func _init() ->void:
	pass
	
func _ready() -> void:
	get_child(0).expand_mode = TextureRect.EXPAND_IGNORE_SIZE


func setup_visuals(instance_id: int, id: String) -> void:
	_instance_id = instance_id
	_card_id = id
	
	var card_data: CommandCard = CardDatabase.get_card(id)
	if not card_data:
		push_error("Card UI: Database missing definition for ", id)
		return

	title_label.text = card_data.title_label
	description_label.text = card_data.description_label
	get_child(0).texture = card_data.card_art

func setup_enemy_visuals(instance_id: int, id: String) -> void:
	_instance_id = instance_id
	
	var card_data: CommandCard = CardDatabase.get_card(id)
	if not card_data:
		push_error("Card UI: Database missing definition for ", id)
		return

	get_child(0).texture = card_data.card_art

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(_instance_id)
