class_name DiscardPileUI
extends Control

@export var top_card_texture: TextureRect

var discard_stack: Array[CardUI] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_CENTER_LEFT)

func get_discard_target_position() -> Vector2:
	if top_card_texture:
		return top_card_texture.global_position + (top_card_texture.size / 2.0)
	return global_position + (size / 2.0)

func add_card_node(card_node: CardUI) -> void:
	card_node.reparent(self)
	card_node.top_level = false
	card_node.position = (size - card_node.size)
	card_node.rotation_degrees = 0.0
	card_node.z_index = discard_stack.size()
	card_node.scale = Vector2(1, 1)
	discard_stack.append(card_node)
