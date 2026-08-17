extends Node
class_name MatchState

var matchId: int
var player_ids: Array[int]
var scores: Dictionary[int, int]
var state: STATE = STATE.INITIALIZING:
	set(newState):
		state = newState
		should_sync = true
var phase: enums.TurnPhase = enums.TurnPhase.DRAW_HAND:
	set(newPhase):
		phase = newPhase
		should_sync = true
var player_turn_index: int:
	set(newIndex):
		player_turn_index = newIndex
		should_sync = true

var should_sync: bool = true
enum STATE {INITIALIZING, READY, INITIALIZE_BOARD, IN_PROGRESS, PAUSED, ENDED}

func _init() -> void:
	name = "matchState"
	Network.Match.sync_requested.connect(_on_sync)

func initialize(matchId: int, player_ids: Array[int]) -> void:
	self.matchId = matchId
	self.player_ids = player_ids
	self.player_turn_index = randi_range(0,1)
	self.scores[player_ids[0]] = 0
	self.scores[player_ids[1]] = 0
	self.phase = enums.TurnPhase.DRAW_HAND

func get_snapshot() -> Dictionary:
	return {
		"matchId": self.matchId,
		"player_ids": self.player_ids,
		"scores": self.scores,
		"state": self.state,
		"phase": self.phase,
		"player_turn_index": self.player_turn_index
	}

func _on_sync(snapshot: Dictionary):
	print("syncing with server")
	matchId = snapshot.matchId
	player_ids = snapshot.player_ids
	scores = snapshot.scores
	state = snapshot.state
	phase = snapshot.phase
	player_turn_index = snapshot.player_turn_index

func sync() -> void:
	if should_sync:
		Network.Match.sync.rpc_id(player_ids[0], get_snapshot())
		Network.Match.sync.rpc_id(player_ids[1], get_snapshot())
		should_sync = false

func is_player_turn(player_id: int) -> bool:
	var index: int = player_ids.find(player_id)
	return index == player_turn_index
	if player_ids.size() > 1:
		self.scores[player_ids[1]] = 0

func is_my_turn() -> bool:
	var index: int = player_ids.find(multiplayer.get_unique_id())
	return index == player_turn_index

func is_phase(phase: enums.TurnPhase) -> bool:
	return self.phase == phase
