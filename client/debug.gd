extends Node2D

@onready var matchState: MatchState = $"../../../matchState"
@onready var phase = $Phase
@onready var turn = $Turn
@onready var peer_ids = $Peer_ids
@onready var state = $State
@onready var scores = $Scores
@onready var winner = $Winner
@onready var button = $Button

@onready var score_pips: Array[TextureRect] = [
	$MarginContainer/ScorePips/TextureRect1,
	$MarginContainer/ScorePips/TextureRect2,
	$MarginContainer/ScorePips/TextureRect3,
	$MarginContainer/ScorePips/TextureRect4,
	$MarginContainer/ScorePips/TextureRect5,
]

var debug_hidden: bool = false

func _ready() -> void:
	update_score_pips()


func _physics_process(delta: float) -> void:
	scores.text = "scores: Red %d - %d Green" % [
		matchState.scores[enums.Side.RED],
		matchState.scores[enums.Side.GREEN]
	]

	peer_ids.text = "Side: " + player_id_text(matchState.mySide)
	phase.text = "turn phase: " + get_turn_phase_txt(matchState.phase)
	state.text = "match state: " + get_game_state_txt(matchState.state)
	turn.text = "player_turn: " + player_id_text(matchState.current_turn)
	winner.text = "winner: " + player_id_text(matchState.winner)

	if matchState.current_turn != matchState.mySide:
		button.text = "Waiting"
		button.disabled = true
	else:
		button.text = get_turn_phase_txt(matchState.phase)
		button.disabled = false

	update_score_pips()

	if Input.is_action_just_released("toggle_debug_overlay"):
		show() if debug_hidden else hide()
		debug_hidden = !debug_hidden


func update_score_pips() -> void:
	var score: int = matchState.scores[matchState.mySide]

	var active_color: Color

	if matchState.mySide == enums.Side.RED:
		active_color = Color.GREEN
	elif matchState.mySide == enums.Side.GREEN:
		active_color = Color.RED
	else:
		active_color = Color.WHITE

	for i in range(score_pips.size()):
		if i < score:
			score_pips[i].modulate = active_color
		else:
			score_pips[i].modulate = Color(0.25, 0.25, 0.25, 1.0)


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
