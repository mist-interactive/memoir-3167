class_name PlayerHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var base_card_size: Vector2 = Vector2(120.0, 220.0)
@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var default_separation: float = 10.0
@onready var handState: HandState = $"../../../../HandState"

func initialize() -> void:
	_clear_hand()
	Network.Card.local_card_received.connect(_on_model_card_added)
	Network.Card.local_card_removed.connect(_on_model_card_removed)
	Network.Actions.hand_drawn_requested.connect(_on_hand_synchronized)
	_on_hand_synchronized()

func _on_hand_synchronized() -> void:
	var hand_data: Dictionary = handState.card_ids
	_clear_hand()
	for instance_id: int in hand_data:
		var card_id: String = hand_data[instance_id]
		_instantiate_card_node(instance_id, card_id)
	_recalculate_layout()

func _on_model_card_added(instance_id: int, card_id: String) -> void:
	_instantiate_card_node(instance_id, card_id)
	_recalculate_layout()

func _on_model_card_removed(instance_id: int) -> void:
	var card_node: Node = get_node_or_null(str(instance_id))
	if card_node:
		remove_child(card_node)
		card_node.queue_free()
		_recalculate_layout()

func _instantiate_card_node(instance_id: int, card_id: String) -> void:
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI
	new_card.name = str(instance_id)
	add_child(new_card)
	new_card.setup_visuals(instance_id, card_id)
	new_card.card_clicked.connect(_on_card_clicked_by_player)

func _recalculate_layout() -> void:
	var card_count: int = get_child_count()
	if card_count == 0:
		return

	var viewport_width: float = get_viewport_rect().size.x
	var available_hand_width: float = viewport_width / 1.5
	
	var separation: float = default_separation
	var total_unscaled_width: float = card_count * base_card_size.x
	var start_x: float = 0.0

	if total_unscaled_width > available_hand_width and card_count > 1:
		# Overlap required: distribute remaining width across gaps
		separation = (available_hand_width - base_card_size.x) / float(card_count - 1) - base_card_size.x
		start_x = (viewport_width - available_hand_width) / 2.0
	else:
		# Centered with fixed spacing
		var total_footprint: float = (card_count * base_card_size.x) + ((card_count - 1) * separation)
		start_x = (viewport_width - total_footprint) / 2.0

	for i: int in range(card_count):
		var card: Control = get_child(i) as Control
		if not card:
			continue

		# Lock size & center pivot point for rotational transform
		card.custom_minimum_size = base_card_size
		card.size = base_card_size
		card.pivot_offset = base_card_size / 2.0

		# Safe curve sampling
		var sample_point: float = 0.5 if card_count == 1 else float(i) / float(card_count - 1)
		var y_multiplier: float = hand_curve.sample(sample_point) if hand_curve else 0.0
		var rot_multiplier: float = rotation_curve.sample(sample_point) if rotation_curve else 0.0

		if card_count == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0

		var target_x: float = start_x + float(i) * (base_card_size.x + separation)
		var target_y: float = y_min + (y_max * y_multiplier)

		card.position = Vector2(target_x, target_y)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier

func _on_card_clicked_by_player(instance_id: int) -> void:
	Network.Card.request_play_card.rpc(instance_id)

func _clear_hand() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
