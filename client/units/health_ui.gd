extends Control

@export var unit: Unit

@onready var health_bar := $HealthBar
@onready var max_health_label := $HealthBar/MaxHealth

var previous_health = 0

var max_health: int = 0: set = _set_max_health, get = _get_max_health
var health: int = 0: set = _set_health, get = _get_health

func _ready() -> void:
	#FIXME: connect these somewhere
	#EventController.connect("on_health_changed", on_event_health_changed)
	#EventController.connect("on_max_health_changed", on_event_max_health_changed)
	#EventController.on_health_ui_ready.emit(player)
	on_event_health_change(unit, 100)
	on_event_max_health_change(unit, 100)

func _set_health(value: int) -> void:
	health = value
	var tween = create_tween()
	tween.tween_property(health_bar, "value", value, 1).set_trans(Tween.TRANS_SINE).set_delay(0.5)

func _get_health() -> int:
	return health

func _set_max_health(value: int) -> void:
	max_health = value
	health_bar.max_value = value
	var tween = create_tween()
	tween.tween_method(_update_max_health_label, previous_health, value, 1)

	previous_health = value

func _update_max_health_label(value: int):
	max_health_label.text = str(value)

func _get_max_health() -> int:
	return max_health

func on_event_health_change(node: Node, new_health: int):
	if node == unit:
		health = new_health

func on_event_max_health_change(node: Node, new_max_health: int):
	if node == unit:
		max_health = new_max_health
