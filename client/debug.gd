extends Control

@onready var matchState: MatchState = $"../../../matchState"
@onready var clock: NetworkClock = $"../../../NetworkClock"
@onready var phase = $ResizeUI/Phase
@onready var turn = $ResizeUI/Turn
@onready var peer_ids = $ResizeUI/Peer_ids
@onready var state = $ResizeUI/State
@onready var scores = $ResizeUI/Scores
@onready var winner = $ResizeUI/Winner
@onready var button = $ResizeUI/Button
@onready var ui = $ResizeUI

const DESIGN_SIZE := Vector2(1920, 1080)
var debug_hidden: bool = false

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


func _ready() -> void:
	get_viewport().size_changed.connect(update_ui)
	update_ui()
	update_score_pips()


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

	peer_ids.text = "Side: " + player_id_text(matchState.mySide)
	phase.text = "turn phase: " + get_turn_phase_txt(matchState.phase) + "(%d)" % (count_down / 1000)
	state.text = "match state: " + get_game_state_txt(matchState.state)
	turn.text = "player_turn: " + player_id_text(matchState.current_turn)
	winner.text = "winner: " + player_id_text(matchState.winner)

	if matchState.current_turn != matchState.mySide:
		button.text = "Waiting"
	else:
		button.text = get_turn_phase_txt(matchState.phase)

	update_score_pips()

	if Input.is_action_just_released("toggle_debug_overlay"):
		show() if debug_hidden else hide()
		debug_hidden = !debug_hidden


func update_score_pips() -> void:
	var my_score: int = matchState.scores[matchState.mySide]
	var enemy_side: enums.Side

	# Determine the enemy side
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

	# Update your score pips
	for i in range(score_pips.size()):
		if i < my_score:
			score_pips[i].modulate = my_active_color
		else:
			score_pips[i].modulate = Color(0.25, 0.25, 0.25, 1.0)

	# Update enemy score pips
	for i in range(score_pips_enemy.size()):
		if i < enemy_score:
			score_pips_enemy[i].modulate = enemy_active_color
		else:
			score_pips_enemy[i].modulate = Color(0.25, 0.25, 0.25, 1.0)



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
			return "Play Card"
		enums.TurnPhase.SELECT:
			return "Select"
		enums.TurnPhase.MOVE:
			return "Move"
		enums.TurnPhase.ATTACK:
			return "Attack"
		enums.TurnPhase.RESOLVE_RETREAT:
			return "Retreat"
		enums.TurnPhase.DRAW_CARD:
			return "Draw Card"
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
