extends Button
@onready var matchState: MatchState = $"../../../matchState"
var isMyTurn: bool

func _process(delta: float) -> void:
	isMyTurn = matchState.is_player_turn(multiplayer.get_unique_id())
	disabled = not isMyTurn

func _on_pressed() -> void:
	Network.Actions.draw_card.rpc_id(1)
