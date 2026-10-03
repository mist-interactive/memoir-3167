extends CanvasLayer
@onready var match_state: MatchState = $"../../matchState"
@onready var network_clock: NetworkClock = $"../../NetworkClock"
@export var player_controller: PlayerController
@export var info_pane: Node2D
@export var info_bg: ColorRect
@export var info_text: RichTextLabel
@export var timer: RichTextLabel
@export var dice_roller: Node3D
@export var battlefield: Node2D

const ally_color: Color = Color(0.329, 0.42, 0.31, 1.0)
const enemy_color: Color = Color(0.596, 0.263, 0.247, 1.0)
const CONFIG_PATH: String = "res://config.json"
var config: Dictionary
var _hide_tween: Tween

var rejoin_window: float
const FONT: Font = preload("res://assets/fonts/PixelArmy/PixelArmy.ttf")

func _ready() -> void:
	visible = false
	match_state.match_state_changed.connect(on_match_state_changed)
	match_state.phase_changed.connect(_on_phase_state_changed)
	battlefield.game_loaded.connect(_on_phase_state_changed)
	get_viewport().size_changed.connect(_center_info_pane)
	_setup_info_text()
	_setup_timer()
	_setup_background()
	_center_info_pane()
	config = ConfigLoader.load_json(CONFIG_PATH)
	rejoin_window = config.match.player_rejoin_window
	if match_state.state == MatchState.STATE.PAUSED:
		on_match_state_changed(MatchState.STATE.PAUSED)

func _process(_delta: float) -> void:
	if match_state.state == MatchState.STATE.PAUSED:
		var server_now: float = network_clock.get_server_time()
		var count_down: int = ceili(((match_state.phase_timer.paused_at + rejoin_window * 1000) - server_now )/ 1000)
		count_down = clampi(count_down, 0, rejoin_window as int)
		timer.text = "Victory in: " + str(count_down)
		timer.offset_transform_position = -Vector2(timer.size.x / 2, -timer.size.y / 3)

func on_match_state_changed(new_state: MatchState.STATE):
	if new_state == MatchState.STATE.ENDED:
		await dice_roller.dice_roll_finished
		await get_tree().create_timer(1.5).timeout
		timer.text = ""
		var winner: int = match_state.get_winner(config.match.max_score)
		if winner == match_state.mySide:
			info_bg.color = Color.DARK_OLIVE_GREEN
			info_text.text = "Victory!"
		else:
			info_bg.color = Color.DARK_RED
			info_text.text = "Defeat!"
		visible = true
	elif new_state == MatchState.STATE.PAUSED:
		info_bg.color = Color.DIM_GRAY
		info_text.text = "Opponent disconnected"
		visible = true
	elif new_state == MatchState.STATE.IN_PROGRESS:
		info_text.text = ""
		visible = false
	call_deferred("_center_info_pane")

func _on_phase_state_changed(new_phase: enums.TurnPhase) -> void:
	if match_state.current_turn == enums.Side.GREEN:
		info_bg.color = ally_color
	else:
		info_bg.color = enemy_color
	var new_phase_str: String = ""
	match new_phase:
		enums.TurnPhase.PLAY_CARD:
			if match_state.is_my_turn():
				new_phase_str = "PLAY A CARD"
			else:
				new_phase_str = "ENEMY PLAYS A CARD"
		enums.TurnPhase.SELECT:
			if match_state.is_my_turn():
				new_phase_str = "SELECT UNITS"
			else:
				new_phase_str = "ENEMY SELECTS UNITS"
		enums.TurnPhase.MOVE:
			if match_state.is_my_turn():
				new_phase_str = "MOVE UNITS"
			else:
				new_phase_str = "ENEMY MOVES UNITS"
		enums.TurnPhase.ATTACK:
			if match_state.is_my_turn():
				new_phase_str = "ATTACK"
			else:
				new_phase_str = "ENEMY ATTACKS"
		enums.TurnPhase.RESOLVE_RETREAT:
			if match_state.is_my_turn():
				new_phase_str = "RETREAT"
			else:
				new_phase_str = "ENEMY RETREATS"
		_:
			new_phase_str = ""
	if new_phase_str != "":
		info_text.text = new_phase_str
		
		call_deferred("_center_info_pane", true)
		if match_state.previous_turn_phase == enums.TurnPhase.RESOLVE_RETREAT && new_phase == enums.TurnPhase.ATTACK:
			return
		visible = true
		if _hide_tween && _hide_tween.is_valid():
			_hide_tween.kill()
		_hide_tween = create_tween()
		_hide_tween.tween_interval(2.0)
		_hide_tween.tween_callback(func(): if match_state.state != MatchState.STATE.PAUSED:
			visible = false)


func _center_info_pane(phase_info: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	info_pane.position = (viewport_size / 2)
	info_text.offset_transform_position = -Vector2(info_text.size.x / 2, info_text.size.y / 2)
	if !phase_info:
		info_bg.modulate.a = 1.0
		info_bg.size = viewport_size / 4
	else:
		info_bg.size = Vector2(viewport_size.x, 40)
		info_bg.modulate.a = 0.5
	info_bg.offset_transform_position = -Vector2(info_bg.size.x / 2, info_bg.size.y / 2)
	timer.offset_transform_position = -Vector2(timer.size.x / 2, -timer.size.y / 3)
	
func _setup_info_text() -> void:
	info_text.clear()
	info_text.add_theme_font_override("normal_font", FONT)
	info_text.add_theme_color_override("default_color", Color.WHITE_SMOKE)
	info_text.add_theme_color_override("font_outline_color", Color.BLACK)
	info_text.add_theme_constant_override("outline_size", 4)
	info_text.add_theme_font_size_override("normal_font_size", 24)
	info_text.set_anchors_preset(Control.PRESET_CENTER)
	info_text.offset_transform_enabled = true
	info_text.fit_content = true
	info_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	
func _setup_timer() -> void:
	timer.clear()
	timer.add_theme_font_override("normal_font", FONT)
	timer.add_theme_color_override("default_color", Color.WHITE_SMOKE)
	timer.add_theme_color_override("font_outline_color", Color.BLACK)
	timer.add_theme_constant_override("outline_size", 3)
	timer.add_theme_font_size_override("normal_font_size", 16)
	timer.set_anchors_preset(Control.PRESET_CENTER)
	timer.offset_transform_enabled = true
	timer.fit_content = true
	timer.autowrap_mode = TextServer.AUTOWRAP_OFF

func _setup_background() ->  void:
	info_bg.offset_transform_enabled = true
	info_bg.set_anchors_preset(Control.PRESET_CENTER)
