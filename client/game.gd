extends Node
@onready var renderGameBoard = preload("res://client/battlefield/battlefield.tscn")

func _ready() -> void:
	print("here")
	Network.Match.init_match_requested.connect(create_new_match)

func create_new_match(battleField: BattlefieldState, matchState: MatchState):
	print("newMatch: ", matchState.matchId)
	add_child(battleField)
	add_child(matchState)
	add_child(renderGameBoard.instantiate())
