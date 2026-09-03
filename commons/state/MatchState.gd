extends Node
class_name MatchState

signal phase_changed(new_phase: enums.TurnPhase)

var matchId: int
var mySide: enums.Side
var scores: Dictionary[enums.Side, int]
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

var should_sync: bool = true
enum STATE {INITIALIZING, READY, INITIALIZE_BOARD, IN_PROGRESS, PAUSED, ENDED}

func _init(snapshot: Dictionary = {}) -> void:
	name = "matchState"
	Network.Match.sync_requested.connect(_on_sync)
	if !snapshot.is_empty():
		_on_sync(snapshot)

func _initialize(match_id: int) -> void:
	self.matchId = match_id
	self.mySide = enums.Side.NONE
	self.scores[enums.Side.GREEN] = 0
	self.scores[enums.Side.RED] = 0
	self.phase = enums.TurnPhase.DRAW_HAND
	self.current_turn = randi_range(enums.Side.GREEN,enums.Side.RED)

func get_snapshot(side: enums.Side = enums.Side.NONE) -> Dictionary:
	return {
		"matchId": self.matchId,
		"scores": self.scores,
		"state": self.state,
		"phase": self.phase,
		"side": side,
		"current_turn": self.current_turn
	}

func _on_sync(snapshot: Dictionary):
	matchId = snapshot.matchId
	scores = snapshot.scores
	state = snapshot.state
	phase = snapshot.phase
	current_turn = snapshot.current_turn
	mySide = snapshot.side
	phase_changed.emit(phase)

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
