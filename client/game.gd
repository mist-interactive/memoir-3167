extends Node
@onready var renderGameBoard = preload("res://client/RenderGameBoard.tscn")

func _ready() -> void:
	print("here")
	Network.create_match_requested.connect(create_new_match)

func create_new_match(gameState: GameState, matchState: MatchState):
	print("newMatch: ", matchState.matchId)
	add_child(gameState)
	add_child(matchState)
	add_child(renderGameBoard.instantiate())
