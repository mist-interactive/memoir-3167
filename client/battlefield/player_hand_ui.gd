class_name PlayerHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var player_controller: Node
@export var discard_pile_ui: DiscardPileUI

@export var base_card_size: Vector2 = Vector2(267.0, 358.0)
@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var default_separation: float = -5.0
@onready var handState: HandState = $"../../../../HandState"

func initialize() -> void:
	_clear_hand()
	Network.Card.local_card_received.connect(_on_model_card_added)
	Network.Actions.card_played_received.connect(_on_model_card_removed)
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

func _on_model_card_removed(peer_id: int, instance_id: int, card_id: String) -> void:
	if multiplayer.get_unique_id() != peer_id:
		print("openent has played card ", card_id)
		# animate opponent played card, should  go to discard pile
		return
	var card_node := get_node_or_null(str(instance_id)) as CardUI
	if not card_node:
		return
	var target_pos: Vector2 = discard_pile_ui.get_discard_target_position() if discard_pile_ui else Vector2.ZERO
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
		separation = (available_hand_width - base_card_size.x) / float(card_count - 1) - base_card_size.x
		start_x = (viewport_width - available_hand_width) / 2.0
	else:
		var total_footprint: float = (card_count * base_card_size.x) + ((card_count - 1) * separation)
		start_x = (viewport_width - total_footprint) / 2.0

	for i: int in range(card_count):
		var card: Control = get_child(i) as Control
		if not card:
			continue

		card.custom_minimum_size = base_card_size
		card.size = base_card_size
		card.pivot_offset = base_card_size / 2.0

		var sample_point: float = 0.5 if card_count == 1 else float(i) / float(card_count - 1)
		var y_multiplier: float = hand_curve.sample(sample_point) if hand_curve else 0.0
		var rot_multiplier: float = rotation_curve.sample(sample_point) if rotation_curve else 0.0

		if card_count == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0

		var target_x: float = start_x + float(i) * (base_card_size.x + separation)
		var target_y: float = y_min + (y_max * y_multiplier)
		
		var target_pos = Vector2(target_x, target_y - base_card_size.y / 2.0)
		var target_rot = max_rotation_degrees * rot_multiplier

		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(card, "position", target_pos, 0.2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "rotation_degrees", target_rot, 0.2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)

func _on_card_clicked_by_player(instance_id: int) -> void:
	Network.Actions.play_card.rpc(instance_id)

func _clear_hand() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
