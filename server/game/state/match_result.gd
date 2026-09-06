class_name MatchResult
extends RefCounted
var match_id: int
var uuids: Array[int]
var winner_uuid: int
var scores: Dictionary[int, int] # uuid --> score
var status: MatchState.STATE

func to_dict() -> Dictionary:
	return {
		"match_id": match_id,
		"uuids": uuids,
		"winner_uuid": winner_uuid,
		"scores": scores,
		"status": status
	}
