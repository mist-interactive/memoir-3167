class_name PhaseTimer
extends RefCounted

var duration: float
var started_at: float
var ends_at: float
var paused_at: float

func get_time_left_ms(state: MatchState.STATE, server_time: float) -> float:
	if state == MatchState.STATE.IN_PROGRESS:
		return ends_at - server_time
	else:
		return duration - (paused_at - started_at)

func to_dict() -> Dictionary:
	return {
		"duration": self.duration,
		"started_at": self.started_at,
		"ends_at": self.ends_at,
		"paused_at": self.paused_at
	}

func sync(snapshot: Dictionary) -> void:
	self.duration = snapshot.duration
	self.started_at = snapshot.started_at
	self.ends_at = snapshot.ends_at
	self.paused_at = snapshot.paused_at
