class_name taskResult
extends RefCounted
var done: bool = false
var err_msg: String = ""

func _init(done: bool = true, err_msg: String = "") -> void:
	self.done = done
	self.err_msg = err_msg
