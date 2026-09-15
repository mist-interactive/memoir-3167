class_name BinaryTree
extends RefCounted

var value: Variant
var left: BinaryTree = null
var right: BinaryTree = null

func _init(value: Variant) -> void:
	self.value = value

func find_node_level(target: Variant) -> int:
	return _get_node_level(self, target, 0)

func _get_node_level(node: BinaryTree, target: Variant, level: int) -> int:
	if node == null:
		return -1
	if node.value == target:
		return level
	var left_level := _get_node_level(node.left, target, level + 1)
	if left_level != -1:
		return left_level
	return _get_node_level(node.right, target, level + 1)
	
func to_array() -> Array[Variant]:
	var arr: Array[Variant] = []
	_to_array(self, arr)
	return arr

func _to_array(node: BinaryTree, arr: Array[Variant]) -> void:
	if node == null:
		return
	arr.append(node.value)
	_to_array(node.left, arr)
	_to_array(node.right, arr)

func print_tree() -> void:
	var nodes: Array[BinaryTree] = [self]
	
	while not nodes.is_empty():
		var node = nodes.pop_front()

		print("Node ", node.value)

		if node.left:
			print("  ├─ left  → ", node.left.value)
			nodes.push_back(node.left)

		if node.right:
			print("  └─ right → ", node.right.value)
			nodes.push_back(node.right)
