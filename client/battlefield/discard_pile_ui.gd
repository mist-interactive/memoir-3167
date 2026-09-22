class_name DiscardPileUI
extends Control

func _ready() -> void:
	position.x = get_viewport_rect().size.x
	position.y = get_viewport_rect().size.y / 2
	set_anchors_preset(Control.PRESET_CENTER_LEFT)

func get_discard_target_position() -> Vector2:
	return global_position + Vector2(size.x, size.y / 2.0)

func add_card_node(card_node: CardUI) -> void:
	card_node.reparent(self, true)
	card_node.top_level = false

	card_node.global_position = get_discard_target_position() - Vector2(
		HandUI.card_size.x / 2.0,
		HandUI.card_size.y / 2.0
	)

	card_node.rotation = 0.0
