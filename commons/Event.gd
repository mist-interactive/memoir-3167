class_name Event
extends RefCounted

var signal_ref: Signal
var args: Array

func _init(signal_ref: Signal, args: Array = []):
	self.signal_ref = signal_ref
	self.args = args

func emit():
	signal_ref.emit.callv(args)
