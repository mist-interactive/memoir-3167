extends Node
class_name GameState
var points: int = 0
var grid: Array[Vector2]
var units
var player_turn: int
var phase: PHASE = PHASE.SELECT
enum PHASE {SELECT, MOVE, COMBAT}

func _init() -> void:
	name = "gameState"

func select_unit(unitId: int) -> void:
	pass

func move_unit(moves: Array[Vector2]):
	pass

func increment_points() -> void:
	points+=1
	
func decrement_points() -> void:
	points-=1
