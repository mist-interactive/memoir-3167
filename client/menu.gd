extends Node
var queuing: bool = false
@onready var queueBtn =  $Button

func _on_button_pressed() -> void:
	if !queuing:
		Network.join_queue.rpc()
		queuing = true
		queueBtn.text = "finding game..."
