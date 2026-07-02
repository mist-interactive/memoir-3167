extends Node
var _next_match_id: int = 0
var peer_to_match: Dictionary = {}
var matches: Dictionary = {}

func _ready() -> void:
	pass

func create_new_match(peerId1: int, peerId2: int) -> void:
	print("Call to create new match")
	var matchState = MatchState.new()
	matchState.matchId = _next_match_id
	matchState.player_ids.append_array([peerId1, peerId2])
	
	var gameState = GameState.new()
	gameState.player_turn = peerId1
	
	var matchNode = Node.new()
	matchNode.name = "Match_%d" % _next_match_id
	matchNode.add_child(gameState)
	matchNode.add_child(matchState)
	get_parent().add_child(matchNode)
	peer_to_match[peerId1] = matchNode
	peer_to_match[peerId2] = matchNode
	matches[_next_match_id] = matchNode
	++_next_match_id
	Network.create_match.rpc_id(peerId1, matchState.matchId, peerId1)
	Network.create_match.rpc_id(peerId2, matchState.matchId, peerId1)
	
func get_peer_match_state(peer: int) -> MatchState:
	return peer_to_match[peer].get_node("matchState")

func get_peer_game_state(peer: int) -> GameState:
	return peer_to_match[peer].get_node("gameState")
