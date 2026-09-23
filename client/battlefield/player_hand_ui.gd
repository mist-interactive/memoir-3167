class_name PlayerHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var player_controller: PlayerController
@export var discard_pile_ui: DiscardPileUI
@export var base_card_size: Vector2 = HandUI.card_size
var card_scale: float = HandUI.card_scale.x

@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var hand_vertical_offset: float = 60.0
@onready var handState: HandState = $"../../../../HandState"
@export var play_area: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_clear_hand()
	handState.hand_drawn.connect(_on_hand_drawn)
	handState.card_played.connect(_on_card_played)
	handState.card_drawn.connect(_on_model_card_added)


func _on_hand_drawn() -> void:
	var hand_data: Dictionary = handState.card_ids
	_clear_hand()

	for instance_id: int in hand_data:
		var card_id: String = hand_data[instance_id]
		_instantiate_card_node(instance_id, card_id)

	_recalculate_layout()


func _on_model_card_added(instance_id: int, card_id: String) -> void:
	_instantiate_card_node(instance_id, card_id)
	_recalculate_layout()


func _on_card_played(instance_id: int, card_id: String) -> void:
	var card_node := get_node_or_null(str(instance_id)) as CardUI

	if not card_node:
		_instantiate_card_node(instance_id, card_id)
		card_node = get_node_or_null(str(instance_id)) as CardUI

	card_node.is_discarded = true
	_remove_card_node_and_animate(card_node, instance_id)


func _remove_card_node_and_animate(card_node: CardUI, instance_id: int) -> void:
	var target_pos: Vector2 = (
		discard_pile_ui.get_discard_target_position()
		if discard_pile_ui
		else Vector2.ZERO
	)

	card_node.animate_to_discard(target_pos, func():
		if discard_pile_ui:
			discard_pile_ui.add_card_node(card_node)

		if handState:
			handState.remove_card(instance_id)

		_recalculate_layout()
	)


func _instantiate_card_node(instance_id: int, card_id: String) -> void:
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI

	new_card.name = str(instance_id)

	new_card.card_hovered.connect(player_controller._on_card_hovered)
	new_card.card_unhovered.connect(player_controller._on_card_unhovered)

	new_card.play_area = play_area

	add_child(new_card)

	new_card.setup_visuals(instance_id, card_id)

	# Scale the card visually
	new_card.scale = Vector2.ONE * card_scale


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalculate_layout()


func _recalculate_layout() -> void:
	var cards: Array[CardUI] = []

	for child in get_children():
		if child is CardUI:
			if child.is_discarded:
				continue

			cards.append(child)

	var card_count := cards.size()

	if card_count == 0:
		return

	# Use scaled dimensions for layout
	var scaled_card_size := base_card_size * card_scale

	var container_width: float = size.x

	# Half-overlap between cards
	var hand_width: float = scaled_card_size.x * card_count

	var start_x: float = (container_width - hand_width) / 2.0

	for i in range(card_count):
		var card := cards[i]

		# Pivot stays based on the card's original local size
		card.pivot_offset = Vector2(
			base_card_size.x / 2.0,
			base_card_size.y
		)

		var sample_point := (
			0.5
			if card_count == 1
			else float(i) / float(card_count - 1)
		)

		var y_multiplier := (
			hand_curve.sample(sample_point)
			if hand_curve
			else 0.0
		)

		var rot_multiplier := (
			rotation_curve.sample(sample_point)
			if rotation_curve
			else 0.0
		)

		if card_count == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0

		var scale_x_offset: float = (
			base_card_size.x * (1.0 - card_scale) / 2.0
		)

		var target_x: float = (
			start_x
			- scale_x_offset
			+ float(i) * scaled_card_size.x
		)

		var target_y: float = (
			size.y
			- base_card_size.y
			+ y_min
			+ (y_max * y_multiplier)
			+ hand_vertical_offset
		)

		var target_pos := Vector2(target_x, target_y)
		var target_rot := max_rotation_degrees * rot_multiplier

		var tween := create_tween().set_parallel(true)

		tween.tween_property(
			card,
			"position",
			target_pos,
			0.2
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			card,
			"rotation_degrees",
			target_rot,
			0.2
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _clear_hand() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
