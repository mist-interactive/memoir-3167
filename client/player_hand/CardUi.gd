class_name CardUI
extends Control

signal card_clicked(instance_id: int)

const SIZE := Vector2(267.0, 358.0)
const BASE_SCALE := Vector2(0.5, 0.5)

@export var title_label: Label
@export var description_label: Label
@onready var background_texture: TextureRect

signal card_drag_started(card: CardUI)
signal card_drag_ended(card: CardUI)

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

var _instance_id: int
var _card_id: String

func _ready() -> void:
	get_child(1).expand_mode = TextureRect.EXPAND_IGNORE_SIZE

func setup_visuals(instance_id: int, id: String) -> void:
	_instance_id = instance_id
	_card_id = id
	
	var card_data: CommandCard = CardDatabase.get_card(id)
	if not card_data:
		push_error("Card UI: Database missing definition for ", id)
		return

	title_label.text = card_data.title_label
	description_label.text = card_data.description_label
	get_child(1).texture = card_data.card_art

func setup_enemy_visuals() -> void:
	var card_data: CommandCard = CardDatabase.get_card("001")
	get_child(1).texture = card_data.card_art

func _on_mouse_exited() -> void:
	z_index = 0
	scale = BASE_SCALE
	position.y += SIZE.y / 3
	get_child(0).visible = false

func _on_mouse_entered() -> void:
	z_index = 10
	scale = scale * 1.5
	position.y -= SIZE.y / 3
	get_child(0).visible = true

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(_instance_id)
	_drag_gui_input(event)

func _drag_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not is_dragging:
			_start_drag()

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - drag_offset
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_end_drag()
			accept_event()

func _start_drag() -> void:
	is_dragging = true
	original_position = global_position
	drag_offset = get_global_mouse_position() - global_position
	z_index = 10
	var hand = get_parent()
	if hand:
		for card in hand.get_children():
			if card is CardUI and card != self:
				card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_drag_started.emit(self)

func _end_drag() -> void:
	if not is_dragging:
		return
	is_dragging = false
	z_index = 0
	var hand = get_parent()
	if hand:
		for card in hand.get_children():
			if card is CardUI:
				card.mouse_filter = Control.MOUSE_FILTER_STOP
		if hand.has_method("_recalculate_layout"):
			hand._recalculate_layout()
	card_drag_ended.emit(self)
