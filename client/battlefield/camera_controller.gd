extends Camera2D

@export var pan_speed: float = 500.0
@export var zoom_speed: float = 0.05

@export var min_zoom: float = 0.15 
@export var max_zoom: float = 0.75 

@export var target_map: TileMapLayer

var IS_MIDDLEMOUSE_DOWN: bool = false

func _ready():
	setup_camera_limits()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Handle zooming with scroll wheel
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP or event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			if event.is_pressed():
				if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
					zoom += Vector2(zoom_speed, zoom_speed)
				if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
					zoom -= Vector2(zoom_speed, zoom_speed)
				zoom.x = clamp(zoom.x, min_zoom, max_zoom)
				zoom.y = clamp(zoom.y, min_zoom, max_zoom)
		# Handle middle mouse button pressed state
		if event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			if event.is_pressed():
				IS_MIDDLEMOUSE_DOWN = true
			if event.is_released():
				IS_MIDDLEMOUSE_DOWN = false
	if event is InputEventMouseMotion and IS_MIDDLEMOUSE_DOWN:
		position -= event.relative / zoom
	pass
		
func _process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		# We divide by zoom.x so the camera pans at the same visual speed 
		# whether you are zoomed way out or right up close to a hex.
		position += direction * pan_speed * delta / zoom.x
		var half_width := get_viewport_rect().size.x / 2 / zoom.x
		var half_height := get_viewport_rect().size.y / 2 / zoom.y
		position.x = clamp(position.x, limit_left + half_width, limit_right - half_width)
		position.y = clamp(position.y, limit_top + half_height, limit_bottom - half_height)
	pass	
		
func setup_camera_limits() -> void:
	if target_map == null:
		push_error("Camera target_map is not assigned")
		return
	var map_rect: Rect2i = target_map.get_used_rect()
	var tile_size: Vector2i = target_map.tile_set.tile_size
	var top_left_center := target_map.map_to_local(map_rect.position)
	var bottom_right_center := target_map.map_to_local(map_rect.end - Vector2i(1, 1))
	
	limit_left = int(top_left_center.x - (tile_size.x / 2))
	limit_right = int(bottom_right_center.x + (tile_size.x / 2))
	limit_top = int(top_left_center.y - (tile_size.y / 2))
	limit_bottom = int(bottom_right_center.y + (tile_size.y / 2))
	pass
