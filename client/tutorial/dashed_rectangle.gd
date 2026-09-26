extends Node2D

@export var dash_length := 10.0
@export var gap_length := 6.0
@export var line_width := 1.0
@export var line_color := Color.RED

@onready var score_pips: Control = $"../../../UI/ResizeUI/UiPlayerOne/ScorePips"


func _ready() -> void:
	get_viewport().size_changed.connect(_update_box)
	_update_box()


func _update_box() -> void:
	if not is_instance_valid(score_pips):
		return

	# Get the ScorePips rectangle in global coordinates.
	var score_rect := score_pips.get_global_rect()

	# Convert the top-left corner from global space
	# into this Node2D's local space.
	var top_left := to_local(score_rect.position)

	# Calculate the global size relative to our coordinate space.
	var top_right := to_local(
		score_rect.position + Vector2(score_rect.size.x, 0.0)
	)

	var bottom_left := to_local(
		score_rect.position + Vector2(0.0, score_rect.size.y)
	)

	var width := top_right.x - top_left.x
	var height := bottom_left.y - top_left.y

	position = Vector2.ZERO

	_box_position = top_left
	_box_size = Vector2(width, height)

	queue_redraw()


var _box_position := Vector2.ZERO
var _box_size := Vector2.ZERO


func _draw() -> void:
	var rect := Rect2(_box_position, _box_size)

	draw_dashed_line(
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		line_color,
		line_width,
		dash_length,
		true
	)

	draw_dashed_line(
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		line_color,
		line_width,
		dash_length,
		true
	)

	draw_dashed_line(
		rect.end,
		Vector2(rect.position.x, rect.end.y),
		line_color,
		line_width,
		dash_length,
		true
	)

	draw_dashed_line(
		Vector2(rect.position.x, rect.end.y),
		rect.position,
		line_color,
		line_width,
		dash_length,
		true
	)
