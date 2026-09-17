extends Node
class_name MatchState

signal phase_changed(new_phase: enums.TurnPhase)
# constants
const DEFAULT_DURATION_IN_SEC = 10

var matchId: int
var mySide: enums.Side
var winner: enums.Side
var scores: Dictionary[enums.Side, int]:
	set(new_score):
		scores = new_score
		should_sync = true
var state: STATE = STATE.INITIALIZING:
	set(newState):
		state = newState
		should_sync = true
var phase: enums.TurnPhase = enums.TurnPhase.DRAW_HAND:
	set(newPhase):
		phase = newPhase
		should_sync = true
var current_turn: enums.Side:
	set(new_turn):
		current_turn = new_turn
		should_sync = true
var phase_timer: PhaseTimer = PhaseTimer.new():
	set(new_phase):
		phase_timer = new_phase
		should_sync = true
var prev_phase_timer: PhaseTimer = PhaseTimer.new()
enum STATE {INITIALIZING, READY, INITIALIZE_BOARD, IN_PROGRESS, PAUSED, ENDED}
var should_sync: bool = true

func _init(snapshot: Dictionary = {}) -> void:
	name = "matchState"
	Network.Match.sync_requested.connect(_on_sync)
	if !snapshot.is_empty():
		_on_sync(snapshot)

func _initialize(match_id: int) -> void:
	self.matchId = match_id
	self.winner = enums.Side.NONE
	self.mySide = enums.Side.NONE
	self.scores[enums.Side.GREEN] = 0
	self.scores[enums.Side.RED] = 0
	self.phase = enums.TurnPhase.DRAW_HAND
	self.current_turn = randi_range(enums.Side.GREEN,enums.Side.RED)

func get_snapshot(side: enums.Side = enums.Side.NONE) -> Dictionary:
	return {
		"matchId": self.matchId,
		"winner": self.winner,
		"scores": self.scores,
		"state": self.state,
		"phase": self.phase,
		"side": side,
		"current_turn": self.current_turn,
		"phase_timer": self.phase_timer.to_dict(),
	}

func _on_sync(snapshot: Dictionary):
	var event_queue: Array[Event]
	if phase != snapshot.phase:
		event_queue.push_back(Event.new(phase_changed, [snapshot.phase]))
	matchId = snapshot.matchId
	winner = snapshot.winner
	scores = snapshot.scores
	state = snapshot.state
	phase = snapshot.phase
	current_turn = snapshot.current_turn
	mySide = snapshot.side
	phase_timer.sync(snapshot.phase_timer)
	for event: Event in event_queue:
		event.emit()

func sync(side_peer_ids: Dictionary[enums.Side, int]) -> void:
	if should_sync:
		for side in side_peer_ids:
			if side_peer_ids[side] < 0:
				continue
			Network.Match.sync.rpc_id(side_peer_ids[side], get_snapshot(side))
		should_sync = false

func is_my_turn() -> bool:
	return current_turn == mySide

func is_phase(phase: enums.TurnPhase) -> bool:
	return self.phase == phase

func get_winner(min_score: int = 1) -> enums.Side:
	if scores[enums.Side.RED] >= min_score:
		return enums.Side.RED
	elif scores[enums.Side.GREEN] >= min_score:
		return enums.Side.GREEN
	return enums.Side.NONE

func is_paused() -> bool:
	return state == STATE.PAUSED

func pause_and_store_phase_timer() -> void:
	prev_phase_timer.sync(phase_timer.to_dict())
	prev_phase_timer.paused_at = Time.get_ticks_msec()

func continue_from_prev_phase_timer() -> void:
	phase_timer.sync(prev_phase_timer.to_dict())
	unpause()
	should_sync = true

func new_phase_timer(duration_in_sec: float = DEFAULT_DURATION_IN_SEC) -> void:
	phase_timer.started_at = Time.get_ticks_msec()
	phase_timer.ends_at = phase_timer.started_at + duration_in_sec * 1000
	phase_timer.duration = duration_in_sec * 1000
	should_sync = true
	
func pause() -> void:
	if state != MatchState.STATE.PAUSED:
		phase_timer.paused_at = Time.get_ticks_msec()
	state = STATE.PAUSED
	should_sync = true
	
func unpause() -> void:
	var time_used: float = phase_timer.paused_at - phase_timer.started_at
	phase_timer.ends_at = Time.get_ticks_msec() + (phase_timer.duration - time_used)
	phase_timer.started_at = phase_timer.ends_at - phase_timer.duration
	state = STATE.IN_PROGRESS

func has_phase_ended(server_time: float) -> bool:
	if state != STATE.IN_PROGRESS:
		return false
	return server_time >= phase_timer.ends_at
