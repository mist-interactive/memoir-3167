extends CanvasLayer
@onready var match_state: MatchState = $"../../matchState"
@onready var network_clock: NetworkClock = $"../../NetworkClock"
@export var info_pane: Node2D
@export var info_bg: ColorRect
@export var info_text: RichTextLabel
@export var timer: RichTextLabel

var pause_time: float

const REJOIN_WINDOW: float = 30
const FONT: Font = preload("res://assets/fonts/PixelArmy/PixelArmy.ttf")

func _ready() -> void:
	visible = false
	match_state.match_state_changed.connect(on_match_state_changed)
	get_viewport().size_changed.connect(_center_info_pane)
	_setup_info_text()
	_setup_timer()
	_setup_background()
	_center_info_pane()

func _process(_delta: float) -> void:
	if match_state.state == MatchState.STATE.PAUSED:
		var server_now: float = network_clock.get_server_time()
		var count_down: int = ceili(((pause_time + REJOIN_WINDOW * 1000) - server_now )/ 1000)
		clampi(count_down, 0, REJOIN_WINDOW)
		timer.text = str(count_down)

func on_match_state_changed(new_state: MatchState.STATE):
	if new_state == MatchState.STATE.ENDED:
		var winner: int = match_state.get_winner()
		if winner == match_state.mySide:
			info_bg.color = Color.DARK_OLIVE_GREEN
			info_text.text = "Victory!"
		else:
			info_bg.color = Color.DARK_RED
			info_text.text = "Defeat!"
		visible = true
	elif new_state == MatchState.STATE.PAUSED:
		pause_time = match_state.phase_timer.paused_at
		info_bg.color = Color.DIM_GRAY
		info_text.text = "Game paused"
		visible = true
	elif new_state == MatchState.STATE.IN_PROGRESS:
		info_text.clear()
		visible = false
	_center_info_pane()

func _center_info_pane() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	info_pane.position = (viewport_size / 2)
	info_text.offset_transform_position = -Vector2(info_text.size.x / 2, info_text.size.y / 2)
	info_bg.size = viewport_size / 6
	info_bg.offset_transform_position = -Vector2(info_bg.size.x / 2, info_bg.size.y / 2)
	timer.offset_transform_position = -Vector2(timer.size.x / 2, -timer.size.y / 3)
	
func _setup_info_text() -> void:
	info_text.clear()
	info_text.add_theme_font_override("font", FONT)
	info_text.add_theme_color_override("font_color", Color.WHITE_SMOKE)
	info_text.add_theme_color_override("font_outline_color", Color.BLACK)
	info_text.add_theme_constant_override("outline_size", 6)
	info_text.add_theme_font_size_override("font_size", 64)
	info_text.set_anchors_preset(Control.PRESET_CENTER)
	info_text.offset_transform_enabled = true
	info_text.fit_content = true
	info_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	
func _setup_timer() -> void:
	timer.clear()
	timer.add_theme_font_override("font", FONT)
	timer.add_theme_color_override("font_color", Color.WHITE_SMOKE)
	timer.add_theme_color_override("font_outline_color", Color.BLACK)
	timer.add_theme_constant_override("outline_size", 6)
	timer.add_theme_font_size_override("font_size", 24)
	timer.set_anchors_preset(Control.PRESET_CENTER)
	timer.offset_transform_enabled = true
	timer.fit_content = true
	timer.autowrap_mode = TextServer.AUTOWRAP_OFF

func _setup_background() ->  void:
	info_bg.offset_transform_enabled = true
	info_bg.set_anchors_preset(Control.PRESET_CENTER)
