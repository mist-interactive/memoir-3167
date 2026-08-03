extends Node2D
@export var findGameBtn: Button
var queuing: bool = false

func _on_find_game_button_down() -> void:
	print("here")
	if !queuing:
		Network.join_queue.rpc()
		queuing = true
		findGameBtn.text = "Cancel"
	else:
		queuing = false
		findGameBtn.text = "Find game"
	pass


func _on_button_button_down() -> void:
	print("jere")
	pass # Replace with function body.
