extends Node2D
@onready var webClient: WebClient = get_node("../../../../../../Client")
@export var connectionStatus: Panel
@onready var connectionStatusStyle: StyleBoxFlat = connectionStatus.get_theme_stylebox("panel")
@onready var reconnectTween = create_tween()

func _ready() -> void:
	webClient.connection_status_change.connect(_on_connection_status_change)
	webClient.reconnection_attempt.connect(_on_reconnection_attempt)
	

func _on_connection_status_change():
	if reconnectTween:
		reconnectTween.kill()
	if webClient.connected:
		connectionStatusStyle.bg_color = Color("298d4e")
	else:
		connectionStatusStyle.bg_color = Color("c23441ff")
		
func _on_reconnection_attempt():
	reconnect_annimation()

func reconnect_annimation():
	if reconnectTween:
		reconnectTween.kill()
	reconnectTween = create_tween()
	reconnectTween.set_loops()
	reconnectTween.tween_property(connectionStatusStyle, "bg_color", Color("a98700ff"), 0.5)
	reconnectTween.tween_interval(0.4)
	reconnectTween.tween_property(connectionStatusStyle, "bg_color", Color("a987008a"), 0.5)
	reconnectTween.tween_interval(0.4)
