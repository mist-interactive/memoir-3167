extends Node2D
@onready var matchState: MatchState = $"../../../matchState"
@onready var phase = $Phase
@onready var turn = $Turn
@onready var peer_ids = $Peer_ids
@onready var state = $State
var debug_hidden: bool = false

func _physics_process(delta: float) -> void:
	peer_ids.text = "player_ids: " + player_id_text(matchState.player_ids[0]) + " | " + player_id_text(matchState.player_ids[1])
	phase.text = "turn phase: " + get_turn_phase_txt(matchState.phase)
	state.text = "match state: " + get_game_state_txt(matchState.state)
	turn.text = "player_turn: " + player_id_text(matchState.player_ids[matchState.player_turn_index])
	if Input.is_action_just_released("toggle_debug_overlay"):
		show() if debug_hidden else hide()
		debug_hidden = !debug_hidden

func player_id_text(id: int) -> String:
	return str(id) + "(me)" if id == multiplayer.get_unique_id() else str(id)

func get_turn_phase_txt(phase: MatchState.TURN_PHASE) -> String:
	match phase:
		MatchState.TURN_PHASE.SPAWN_UNITS:
			return "Spawn Units"
		MatchState.TURN_PHASE.DRAW_HAND:
			return "Draw Hand"
		MatchState.TURN_PHASE.PLAY_CARD:
			return "Play Card"
		MatchState.TURN_PHASE.SELECT:
			return "Select"
		MatchState.TURN_PHASE.MOVE:
			return "Move"
		MatchState.TURN_PHASE.ATTACK:
			return "Attack"
		MatchState.TURN_PHASE.DRAW_CARD:
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
