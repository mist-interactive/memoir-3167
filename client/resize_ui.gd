extends Control

@onready var ui = $Control

const DESIGN_SIZE := Vector2(1920, 1080)

func _ready():
	get_viewport().size_changed.connect(update_ui)
	update_ui()

func update_ui():
	var viewport_size = get_viewport_rect().size

	var scale_factor = min(
		viewport_size.x / DESIGN_SIZE.x,
		viewport_size.y / DESIGN_SIZE.y
	)

	ui.scale = Vector2.ONE * scale_factor
	ui.position = (viewport_size - DESIGN_SIZE * scale_factor) / 2
