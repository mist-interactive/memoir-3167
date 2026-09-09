class_name _Node
extends RefCounted
var value: Variant
var prev: _Node = null
var next: _Node = null

func _init(value: Variant, prev_node: _Node = null) -> void:
	self.value = value
	self.prev = prev_node
