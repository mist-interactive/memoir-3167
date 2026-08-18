extends Node2D
@export var webClient: WebClient
@export var findGameBtn: Button
@export var uuid: TextEdit
var queuing: bool = false

func _ready() -> void:
	webClient.connection_status_change.connect(_on_connection_status_change)
	hide()
	uuid.text = str(randi_range(0, 99999))
	

func _on_find_game_button_down() -> void:
	if !webClient.connected:
		return
	if !queuing && !uuid.text.is_empty():
		Network.join_queue.rpc(int(uuid.text))
		queuing = true
		findGameBtn.text = "Cancel"
	else:
		queuing = false
		findGameBtn.text = "Find game"
	pass

func _on_connection_status_change() -> void:
	if queuing && !webClient.connected:
		findGameBtn.text = "Find game"
