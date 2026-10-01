class_name DashedLine2D

extends Node2D

@export var line_width: float = 3.0
@export var line_color: Color = Color.RED
@export var dash_length: float = 12.0
@export var gap_length: float = 8.0

var line_start: Vector2
var line_end: Vector2


func set_line(start: Vector2, end: Vector2) -> void:
	line_start = start
	line_end = end
	queue_redraw()

func _draw() -> void:
	var direction := line_end - line_start
	var length := direction.length()

	if length <= 0.0:
		return

	var normal := direction.normalized()
	var distance := 0.0

	while distance < length:
		var dash_start := distance
		var dash_end := minf(distance + dash_length, length)

		draw_line(
			line_start + normal * dash_start,
			line_start + normal * dash_end,
			line_color,
			line_width
		)

		distance += dash_length + gap_length
