extends Control

@onready var matchState: MatchState = $"../../../matchState"
@onready var clock: NetworkClock = $"../../../NetworkClock"

@onready var ui = $ResizeUI

@onready var phase = $ResizeUI/Phase
@onready var turn = $ResizeUI/Turn
@onready var peer_ids = $ResizeUI/Peer_ids
@onready var state = $ResizeUI/State
@onready var scores = $ResizeUI/Scores
@onready var winner = $ResizeUI/Winner
@onready var button = $ResizeUI/Button
@onready var next_phase = $ResizeUI/NextPhase
@onready var my_faction = $ResizeUI/MyFaction
@onready var enemy_faction = $ResizeUI/EnemyFaction

@export var bottom_colored_bar: TextureRect
@export var top_colored_bar: TextureRect

const DESIGN_SIZE := Vector2(1920, 1080)
var debug_hidden: bool = false
const ALLIES := "Allies"
const AXIS := "Axis"

@onready var score_pips: Array[TextureRect] = [
	$ResizeUI/ScorePips/BoxContainer/TextureRect1,
	$ResizeUI/ScorePips/BoxContainer/TextureRect2,
	$ResizeUI/ScorePips/BoxContainer/TextureRect3,
	$ResizeUI/ScorePips/BoxContainer/TextureRect4,
	$ResizeUI/ScorePips/BoxContainer/TextureRect5,
]

@onready var score_pips_enemy: Array[TextureRect] = [
	$ResizeUI/ScorePipsEnemy/BoxContainer/TextureRect1,
	$ResizeUI/ScorePipsEnemy/BoxContainer/TextureRect2,
	$ResizeUI/ScorePipsEnemy/BoxContainer/TextureRect3,
	$ResizeUI/ScorePipsEnemy/BoxContainer/TextureRect4,
	$ResizeUI/ScorePipsEnemy/BoxContainer/TextureRect5,
]

const ally_color: Color = Color(0.329, 0.42, 0.31, 1.0)
const enemy_color: Color = Color(0.596, 0.263, 0.247, 1.0)

func _ready() -> void:
	get_viewport().size_changed.connect(update_ui)
	update_ui()
	update_score_pips()

func update_player_color() -> void:
	match matchState.mySide:
		enums.Side.RED:
			my_faction.text = AXIS
			enemy_faction.text = ALLIES
			var style = my_faction.get_theme_stylebox("normal") as StyleBoxFlat
			style.bg_color = enemy_color
			style = enemy_faction.get_theme_stylebox("normal") as StyleBoxFlat
			style.bg_color = ally_color
		enums.Side.GREEN:
			my_faction.text = ALLIES
			enemy_faction.text = AXIS
			var style = my_faction.get_theme_stylebox("normal") as StyleBoxFlat
			style.bg_color = ally_color
			style = enemy_faction.get_theme_stylebox("normal") as StyleBoxFlat
			style.bg_color = enemy_color
		enums.Side.NONE:
			return

func update_ui():
	var viewport_size := get_viewport_rect().size
	var scale_factor := minf(
		viewport_size.x / DESIGN_SIZE.x,
		viewport_size.y / DESIGN_SIZE.y
	)
	ui.scale = Vector2.ONE * scale_factor
	ui.position = (viewport_size - DESIGN_SIZE * scale_factor) / 2.0

func _physics_process(delta: float) -> void:
	var server_now: float = clock.get_server_time()
	var count_down: float = matchState.phase_timer.get_time_left_ms(matchState.state, server_now)
	scores.text = "scores: Red %d - %d Green" % [
		matchState.scores[enums.Side.RED],
		matchState.scores[enums.Side.GREEN]
	]
	
	if matchState.mySide != enums.Side.NONE:
		update_player_color()

	peer_ids.text = "Side: " + player_id_text(matchState.mySide)
	phase.text = "turn phase: " + get_turn_phase_txt(matchState.phase) + "(%d)" % (count_down / 1000)
	state.text = "match state: " + get_game_state_txt(matchState.state)
	turn.text = "player_turn: " + player_id_text(matchState.current_turn)
	winner.text = "winner: " + player_id_text(matchState.winner)

	var is_my_turn := matchState.is_my_turn()

	# Only show phase information during your turn.
	phase.visible = is_my_turn
	next_phase.visible = is_my_turn

	if is_my_turn:
		phase.text = get_turn_phase_txt(matchState.phase) + "(%d)" % (count_down / 1000)
		next_phase.text = "To " + get_turn_phase_txt(get_next_phase())
		button.text = "Next"
	else:
		button.text = "Opponent's Turn"

	update_score_pips()

	if Input.is_action_just_released("toggle_debug_overlay"):
		show() if debug_hidden else hide()
		debug_hidden = !debug_hidden


func get_next_phase() -> enums.TurnPhase:
	match matchState.phase:
		enums.TurnPhase.SPAWN_UNITS:
			return enums.TurnPhase.DRAW_HAND

		enums.TurnPhase.DRAW_HAND:
			return enums.TurnPhase.PLAY_CARD

		enums.TurnPhase.PLAY_CARD:
			return enums.TurnPhase.SELECT

		enums.TurnPhase.SELECT:
			return enums.TurnPhase.MOVE

		enums.TurnPhase.MOVE:
			return enums.TurnPhase.ATTACK

		enums.TurnPhase.ATTACK:
			return enums.TurnPhase.DRAW_CARD

		enums.TurnPhase.DRAW_CARD:
			return enums.TurnPhase.SPAWN_UNITS

	return enums.TurnPhase.SPAWN_UNITS


func update_score_pips() -> void:
	var my_score: int = matchState.scores[matchState.mySide]
	var enemy_side: enums.Side

	if matchState.mySide == enums.Side.RED:
		enemy_side = enums.Side.GREEN
	elif matchState.mySide == enums.Side.GREEN:
		enemy_side = enums.Side.RED
	else:
		enemy_side = enums.Side.NONE

	var enemy_score: int = matchState.scores[enemy_side]

	var my_active_color: Color
	var enemy_active_color: Color

	# Your pips use the enemy's color
	if matchState.mySide == enums.Side.RED:
		my_active_color = Color.GREEN
		enemy_active_color = Color.RED
	elif matchState.mySide == enums.Side.GREEN:
		my_active_color = Color.RED
		enemy_active_color = Color.GREEN
	else:
		my_active_color = Color.WHITE
		enemy_active_color = Color.WHITE

	for i in range(score_pips.size()):
		if i < my_score:
			score_pips[i].modulate = my_active_color
		else:
			score_pips[i].modulate = Color(0.722, 0.722, 0.722, 1.0)

	for i in range(score_pips_enemy.size()):
		if i < enemy_score:
			score_pips_enemy[i].modulate = enemy_active_color
		else:
			score_pips_enemy[i].modulate = Color(0.722, 0.722, 0.722, 1.0)


func player_id_text(side: enums.Side) -> String:
	if side == enums.Side.GREEN:
		return "Green"
	elif side == enums.Side.RED:
		return "Red"
	else:
		return "None"


func get_turn_phase_txt(phase: enums.TurnPhase) -> String:
	match phase:
		enums.TurnPhase.SPAWN_UNITS:
			return "Spawn Units"
		enums.TurnPhase.DRAW_HAND:
			return "Draw Hand"
		enums.TurnPhase.PLAY_CARD:
			return "Play a Card"
		enums.TurnPhase.SELECT:
			return "Select Units"
		enums.TurnPhase.MOVE:
			return "Move Units"
		enums.TurnPhase.ATTACK:
			return "Attack"
		enums.TurnPhase.RESOLVE_RETREAT:
			return "Retreat"
		enums.TurnPhase.DRAW_CARD:
			return "Draw a Card"

	return "Unknown"


func get_game_state_txt(state: MatchState.STATE) -> String:
	match state:
		MatchState.STATE.INITIALIZING:
			return "Initializing"
		MatchState.STATE.READY:
			return "Ready"
		MatchState.STATE.INITIALIZE_BOARD:
			return "Initialize Board"
		MatchState.STATE.IN_PROGRESS:
			return "In Progress"
		MatchState.STATE.PAUSED:
			return "Paused"
		MatchState.STATE.ENDED:
			return "Ended"

	return "Unknown"


func _on_confirm() -> void:
	match matchState.phase:
		enums.TurnPhase.SELECT:
			Network.Actions.continue_to_next_phase.rpc_id(1)

		enums.TurnPhase.MOVE:
			Network.Actions.continue_to_next_phase.rpc_id(1)

		enums.TurnPhase.ATTACK:
			Network.Actions.continue_to_next_phase.rpc_id(1)
