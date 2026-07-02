extends Node2D
@onready var gameState: GameState = $"../gameState"
@onready var matchState: MatchState = $"../matchState"
@onready var playerTurn = $PlayerTurn
@onready var matchId = $MatchId
@onready var points = $Points
@onready var menu = $"../../UI/Menu"
@onready var add = $AddPoints
@onready var remove = $RemovePoints

func _ready() -> void:
	menu.queue_free()
	pass

func _process(delta: float) -> void:
	if gameState.player_turn == Network.multiplayer.get_unique_id():
		add.disabled = true
		remove.disabled = true
	else:
		add.disabled = false
		remove.disabled = false
	matchId.text = "MatchId: %d" % matchState.matchId
	playerTurn.text = "Player turn: %d" % gameState.player_turn
	points.text = "Poings: %d" % gameState.points


func _on_remove_points_pressed() -> void:
	pass # Replace with function body.


func _on_add_points_pressed() -> void:
	pass # Replace with function body.
