class_name CardUI
extends Control

var SIZE := HandUI.card_size
var BASE_SCALE := HandUI.card_scale
const DISCARD_BASE_SCALE := Vector2(1.0, 1.0)
const DRAG_THRESHOLD := 8.0

var CLICK_SCALE := BASE_SCALE
var HOVER_SCALE := BASE_SCALE * 1.35

const CARD_Z_INDEX := 1000
const DRAG_Z_INDEX := 100000

@export var background_texture: TextureRect
@export var play_area: Control
@export var discard_target: Control

@onready var handState: HandState = $"../../../../../HandState"

static var active_drag_card: CardUI = null

signal card_drag_started(card: CardUI)
signal card_drag_ended(card: CardUI)

signal card_hovered(target_sector: enums.MapSector)
signal card_unhovered

var just_returned_to_hand: bool = false
var is_dragging: bool = false
var is_mouse_pressed: bool = false
var press_position: Vector2 = Vector2.ZERO
var is_mouse_over: bool = false

var drag_offset: Vector2 = Vector2.ZERO
var base_position_x: float

var _instance_id: int
var _card_id: String
var is_interactive: bool = true
var is_discarded: bool = false

var cursor_normal: Texture2D
var cursor_hover: Texture2D
var cursor_drag: Texture2D


func _ready() -> void:
	size = HandUI.card_size
	scale = HandUI.card_scale

	# Always render above other Controls in the same CanvasLayer.
	z_as_relative = false
	z_index = CARD_Z_INDEX

	cursor_normal = load("res://assets/sprites/cursor/Normal-3.png")
	cursor_hover = load("res://assets/sprites/cursor/Move_2-3.png")
	cursor_drag = load("res://assets/sprites/cursor/Move_1-3.png")


func set_cursor_normal() -> void:
	Input.set_custom_mouse_cursor(
		cursor_normal,
		Input.CURSOR_ARROW,
		Vector2(8, 8)
	)


func set_cursor_hover() -> void:
	Input.set_custom_mouse_cursor(
		cursor_hover,
		Input.CURSOR_ARROW,
		Vector2(32, 32)
	)


func set_cursor_drag() -> void:
	Input.set_custom_mouse_cursor(
		cursor_drag,
		Input.CURSOR_ARROW,
		Vector2(32, 32)
	)


func update_cursor() -> void:
	if is_dragging:
		set_cursor_drag()
	elif is_mouse_over and is_interactive and not is_discarded:
		set_cursor_hover()
	else:
		set_cursor_normal()


func setup_visuals(instance_id: int, id: String) -> void:
	_instance_id = instance_id
	_card_id = id

	var card_data: CommandCard = CardDatabase.get_card(id)
	if not card_data:
		push_error("Card UI: Database missing definition for ", id)
		return

	$background_texture.texture = card_data.load_card_art()


func setup_enemy_visuals(instance_id: int) -> void:
	var card_data: CommandCard = CardDatabase.get_card("000")

	_instance_id = instance_id
	$background_texture.texture = card_data.load_card_art()

	mouse_default_cursor_shape = Control.CURSOR_ARROW
	is_interactive = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$background_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$background_texture.flip_h = true
	$background_texture.flip_v = true


func animate_to_discard(
	target_global_pos: Vector2,
	on_complete_callback: Callable
) -> void:
	is_discarded = true
	is_interactive = false
	is_mouse_over = false
	set_cursor_normal()

	if is_dragging:
		_end_drag()

	_reset_hover_state()

	var start_global_pos := global_position

	top_level = true
	global_position = start_global_pos

	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var target_scale := get_discard_scale()
	var final_pos := target_global_pos - (size * target_scale) / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"global_position",
		final_pos,
		0.4
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"scale",
		target_scale,
		0.4
	).set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(
		self,
		"rotation_degrees",
		0.0,
		0.4
	).set_trans(Tween.TRANS_CUBIC)

	tween.set_parallel(false)

	tween.tween_callback(func():
		if on_complete_callback.is_valid():
			on_complete_callback.call()
	)


func _reset_hover_state() -> void:
	z_index = CARD_Z_INDEX
	scale = BASE_SCALE

	if get_child_count() > 0:
		get_child(0).visible = false

	card_unhovered.emit()


func _on_mouse_exited() -> void:
	is_mouse_over = false

	if not is_interactive:
		set_cursor_normal()
		return

	# While dragging, the mouse leaving the card is expected.
	# Don't reset hover state or emit unhovered.
	if is_dragging:
		return

	if is_discarded:
		set_cursor_normal()
		_animate_discard_pile_hover(0)
		return

	just_returned_to_hand = false

	if not is_mouse_pressed:
		z_index = 0
		scale = BASE_SCALE

	set_cursor_normal()

	card_unhovered.emit()


func _on_mouse_entered() -> void:
	is_mouse_over = true

	if not is_interactive:
		set_cursor_normal()
		return

	if is_dragging:
		return

	if is_discarded:
		_animate_discard_pile_hover(1)
		return

	z_index = CARD_Z_INDEX + 1
	scale = HOVER_SCALE
	set_cursor_hover()

	var card_data: CommandCard = CardDatabase.get_card(_card_id)
	if card_data:
		card_hovered.emit(card_data.target_sector)


func _animate_discard_pile_hover(state: int) -> void:
	var discard_scale := get_discard_scale()

	if state == 1:
		scale = discard_scale * 1.5
		base_position_x = position.x
		position.x -= size.x * 0.25
	else:
		scale = discard_scale
		position.x = base_position_x


func get_discard_scale() -> Vector2:
	if not discard_target:
		return BASE_SCALE

	var parent_global_scale := discard_target.global_transform.get_scale() as Vector2

	return Vector2(
		BASE_SCALE.x / parent_global_scale.x,
		BASE_SCALE.y / parent_global_scale.y
	)


func _gui_input(event: InputEvent) -> void:
	if not is_interactive or is_discarded:
		return

	# Don't allow any other card to interact while another card is dragging.
	if active_drag_card != null and active_drag_card != self:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return

		if mouse_event.pressed:
			is_mouse_pressed = true
			press_position = get_global_mouse_position()
			accept_event()
		else:
			if not is_dragging:
				is_mouse_pressed = false
				accept_event()

	elif event is InputEventMouseMotion:
		if is_mouse_pressed and not is_dragging:
			var mouse_position := get_global_mouse_position()

			if mouse_position.distance_to(press_position) >= DRAG_THRESHOLD:
				_start_drag()


func _input(event: InputEvent) -> void:
	if not is_interactive:
		return

	if active_drag_card != self:
		return

	if not is_dragging:
		return

	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - drag_offset

	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_end_drag()
			accept_event()


func _start_drag() -> void:
	if is_dragging:
		return

	active_drag_card = self
	is_dragging = true
	is_mouse_pressed = true

	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	var hand := get_parent()

	if hand:
		for card in hand.get_children():
			if card is CardUI and card != self:
				card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	scale = HOVER_SCALE
	rotation_degrees = 0.0

	# Put the dragged card above all other cards.
	z_as_relative = false
	z_index = DRAG_Z_INDEX

	drag_offset = get_global_mouse_position() - global_position

	set_cursor_drag()

	card_drag_started.emit(self)


func _end_drag() -> void:
	if not is_dragging:
		return

	is_dragging = false
	is_mouse_pressed = false
	z_as_relative = false
	z_index = CARD_Z_INDEX
	scale = BASE_SCALE

	# Allow the cursor to leave the game window again.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_unlock_cards()

	if active_drag_card == self:
		active_drag_card = null

	if is_over_play_area():
		var drop_pos := global_position

		top_level = true
		global_position = drop_pos

		Network.Actions.play_card.rpc(_instance_id)

		var confirmed := await _wait_for_card_confirmation(0.1)

		if confirmed:
			var target_pos := Vector2.ZERO

			if discard_target:
				target_pos = discard_target.global_position + (discard_target.size / 2.0)

			animate_to_discard(
				target_pos,
				func():
					queue_free()

					var hand := get_parent()
					if hand and hand.has_method("_recalculate_layout"):
						hand._recalculate_layout()
			)
		else:
			return_to_hand()
	else:
		return_to_hand()

	update_cursor()
	card_drag_ended.emit(self)


func _unlock_cards() -> void:
	var hand := get_parent()

	if hand:
		for card in hand.get_children():
			if card is CardUI:
				card.mouse_filter = (
					Control.MOUSE_FILTER_STOP
					if card.is_interactive
					else Control.MOUSE_FILTER_IGNORE
				)


func _wait_for_card_confirmation(timeout_seconds: float) -> bool:
	if not handState:
		return false

	var confirmed := false

	var on_played := func(confirmed_id: int, _c_id: String):
		if confirmed_id == _instance_id:
			confirmed = true

	handState.card_played.connect(on_played)

	var timer := get_tree().create_timer(timeout_seconds)

	while not confirmed and timer.time_left > 0:
		await get_tree().process_frame

	if handState.card_played.is_connected(on_played):
		handState.card_played.disconnect(on_played)

	return confirmed


func return_to_hand() -> void:
	top_level = false
	scale = BASE_SCALE
	rotation_degrees = 0.0
	z_index = CARD_Z_INDEX

	just_returned_to_hand = true

	var hand := get_parent()

	if hand and hand.has_method("_recalculate_layout"):
		hand._recalculate_layout()


func is_over_play_area() -> bool:
	if not play_area:
		return false

	var card_center := global_position + size * 0.5
	return play_area.get_global_rect().has_point(card_center)
