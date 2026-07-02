extends Node
signal join_queue_requested(peer_id: int)
signal create_match_requested(gameState: GameState, matchState: MatchState)

@rpc("any_peer","call_remote")
func join_queue() -> void:
	print("calling to server")
	join_queue_requested.emit(multiplayer.get_remote_sender_id())

@rpc("authority", "call_remote")
func create_match(matchId: int, playerTurn: int) -> void:
	print("creating game")
	var gameState: GameState = GameState.new()
	gameState.player_turn = playerTurn
	var matchState: MatchState = MatchState.new()
	matchState.matchId = matchId
	create_match_requested.emit(gameState, matchState)

@rpc("any_peer", "call_remote")
func increment_point() -> void:
	pass

@rpc("authority", "call_remote")
func newPoints() -> void:
	pass
