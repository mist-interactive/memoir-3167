class_name EnemyHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var base_card_size: Vector2 = HandUI.card_size
@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var default_separation: float = -5.0
@export var hand_vertical_offset: float = 30.0
@onready var handState: HandState = $"../../../../HandState"
@export var discard_pile_ui: DiscardPileUI
@export var player_controller: PlayerController

func _ready() -> void:
	handState.enemy_hand_drawn.connect(_on_enemy_draw_hand)
	handState.enemy_card_drawn.connect(_on_enemy_card_drawn)
	handState.enemy_card_played.connect(_on_enemy_played_card)

func _on_enemy_draw_hand() -> void:
	for instance_id in handState.opponent_cards:
		_add_card_node(instance_id)
	_recalculate_layout()

func _on_enemy_card_drawn(instance_id: int) -> void:
	_add_card_node(instance_id)
	_recalculate_layout()

func _add_card_node(instance_id: int) -> void:
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI
	new_card.name = str(instance_id)
	new_card.setup_enemy_visuals(instance_id)
	new_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(new_card)
	_recalculate_layout()

func _on_enemy_played_card(instance_id: int, card_id: String) -> void:
	var card_node := get_node_or_null(str(instance_id)) as CardUI

	if not card_node:
		_add_card_node(instance_id)
		card_node = get_node_or_null(str(instance_id)) as CardUI

	card_node.is_discarded = true
	card_node.setup_visuals(instance_id, card_id)
	_remove_card_node_and_animate(card_node, instance_id)
	_recalculate_layout()
	return

func _remove_card_node_and_animate(card_node: CardUI, instance_id: int) -> void:
	var target_pos: Vector2 = (
		discard_pile_ui.get_discard_target_position()
		if discard_pile_ui
		else Vector2.ZERO
	)

	card_node.animate_to_discard(target_pos, func():
		if discard_pile_ui:
			discard_pile_ui.add_card_node(card_node)
	)

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

	var container_width: float = size.x

	var hand_width: float = (
		base_card_size.x
		+ (card_count - 1) * (base_card_size.x / 2.0)
	)

	var start_x: float = (container_width - hand_width) / 2.0

	for i in range(card_count):
		var card := cards[i]

		card.custom_minimum_size = base_card_size
		card.size = base_card_size
		card.pivot_offset = base_card_size / 2.0

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

		var target_x: float = start_x + (float(i) * base_card_size.x) / 2.0

		var target_y: float = (
			y_min
			+ (y_max * y_multiplier)
			+ hand_vertical_offset
		)

		card.position = Vector2(
			target_x,
			target_y - base_card_size.y / 2.0
		)

		card.rotation_degrees = max_rotation_degrees * rot_multiplier
