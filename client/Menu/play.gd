extends Node2D
@onready var webClient: WebClient = get_node("../../../../../Client")
@export var findGameBtn: Button
var queuing: bool = false

func _ready() -> void:
	webClient.connection_status_change.connect(_on_connection_status_change)

func _on_find_game_button_down() -> void:
	if !webClient.connected:
		return
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

func _on_connection_status_change() -> void:
	if queuing && !webClient.connected:
		findGameBtn.text = "Find game"
