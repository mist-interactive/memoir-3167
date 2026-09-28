class_name DiscardPileUI
extends Control

func get_discard_target_position() -> Vector2:
	return global_position + Vector2(size.x, size.y / 2.0)

func add_card_node(card_node: CardUI) -> void:
	card_node.reparent(self, true)
	card_node.top_level = false

	var scaled_card_size := card_node.size * card_node.scale

	card_node.global_position = (
		get_discard_target_position()
		- scaled_card_size / 2.0
	)

	card_node.rotation = 0.0
