extends Node2D
@onready var matchState: MatchState = $"../../../matchState"
@onready var phase = $Phase
@onready var turn = $Turn
@onready var peer_ids = $Peer_ids
@onready var state = $State
var debug_hidden: bool = false

func _physics_process(delta: float) -> void:
	peer_ids.text = "Side: " + player_id_text(matchState.mySide)
	phase.text = "turn phase: " + get_turn_phase_txt(matchState.phase)
	state.text = "match state: " + get_game_state_txt(matchState.state)
	turn.text = "player_turn: " + player_id_text(matchState.current_turn)
	if Input.is_action_just_released("toggle_debug_overlay"):
		show() if debug_hidden else hide()
		debug_hidden = !debug_hidden

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
