class_name DoublyLinkedList
extends RefCounted
var head: _Node
var tail: _Node

func _init(head: _Node) -> void:
	self.head = head
	self.tail = head

func append(next: _Node) -> void:
	var curr: _Node = head
	next.prev = tail
	while curr != null:
		if curr.next == null:
			curr.next = next
			tail = next
			break
		curr = curr.next

func remove_tail() ->  void:
	var prev: _Node = null
	var curr: _Node = head
	if curr.next == null:
		curr == null
		return
	while curr != null:
		if curr.next == null:
			#curr.free()
			tail = prev
			tail.next = null
			break
		prev = curr
		curr = curr.next

func head_is_tail() -> bool:
	return head == tail

func get_head() -> _Node:
	return head

func get_head_value() -> Variant:
	return head.value

func get_tail() -> _Node:
	return tail

func get_tail_value() -> Variant:
	return tail.value
