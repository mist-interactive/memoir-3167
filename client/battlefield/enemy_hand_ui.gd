class_name EnemyHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var base_card_size: Vector2 = Vector2(267.0, 358.0)
@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var default_separation: float = -5.0
@onready var handState: HandState = $"../../../../HandState"

func _ready() -> void:
	Network.Actions.enemy_hand_size_changed.connect(_on_enemy_hand_size_changed)

func _on_enemy_hand_size_changed(new_size: int) -> void:
	while new_size < get_child_count():
		_remove_card_node()
	while new_size > get_child_count():
		_add_card_node()
	_recalculate_layout()

func initialize(peer_id: int) -> void:
	_on_hand_synchronized(peer_id)

func _on_hand_synchronized(peer_id: int) -> void:
	for id in range(handState.opponent_hand_size):
		_add_card_node()
	_recalculate_layout()

func _add_card_node() -> void:
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI
	add_child(new_card)
	new_card.setup_enemy_visuals()
	new_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _remove_card_node() -> void:
	var card = get_child(-1)
	remove_child(card)
	card.queue_free()

# dont worry about it
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
		
		var canvas_size: Vector2 = get_viewport_rect().size
		
		card.position = Vector2(target_x, target_y - base_card_size.y / 2)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
