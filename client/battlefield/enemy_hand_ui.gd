class_name EnemyHandUI
extends Control

@export var card_ui_scene: PackedScene
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var base_card_size: Vector2 = Vector2(200.0, 310.0)
@export var max_rotation_degrees: float = 5.0
@export var y_min: float = 0.0
@export var y_max: float = -15.0
@export var default_separation: float = -5.0
@onready var handState: HandState = $"../../../../HandState"
@export var discard_pile_ui: DiscardPileUI
@export var player_controller: PlayerController 

func _ready() -> void:
	handState.enemy_hand_drawn.connect(_on_enemy_draw_hand)
	handState.enemy_card_played.connect(_on_enemy_played_card)

func _on_enemy_draw_hand() -> void:
	for id in range(handState.opponent_hand_size):
		_add_card_node()
	_recalculate_layout()

func _add_card_node() -> void:
	var new_card: CardUI = card_ui_scene.instantiate() as CardUI
	var instance_id: int = 1000
	new_card.name = str(instance_id)
	new_card.setup_enemy_visuals(instance_id)
	new_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(new_card)
	_recalculate_layout()

func _on_enemy_played_card(instance_id: int, card_id: String) -> void:
	var card_node = get_child(randi_range(0, get_child_count() - 1)) as CardUI
	card_node.is_discarded = true
	card_node.setup_visuals(instance_id, card_id)
	_remove_card_node_and_animate(card_node, instance_id)
	_recalculate_layout()
	return

func _remove_card_node_and_animate(card_node: CardUI, instance_id: int) -> void:
	var target_pos: Vector2 = discard_pile_ui.get_discard_target_position() if discard_pile_ui else Vector2.ZERO
	card_node.animate_to_discard(target_pos, func():
		if discard_pile_ui:
			discard_pile_ui.add_card_node(card_node)
	)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalculate_layout()

# dont worry about it
func _recalculate_layout() -> void:
	var card_count: int = get_child_count()
	if card_count == 0:
		return
		
	var viewport_width: float = size.x
	print("viewport_width: ", viewport_width)
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
