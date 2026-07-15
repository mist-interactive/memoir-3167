extends Node
class_name MatchManager
var _next_match_id: int = 0
var peer_to_match: Dictionary[int, int] = {}
var matches: Dictionary[int, matchController] = {}

func _ready() -> void:
	Network.Match.connect_match_requested.connect(_on_player_connect)

func create_new_match(peerId1: int, peerId2: int) -> void:
	print("Call to create new match")
	var matchState = MatchState.new(_next_match_id, [peerId1, peerId2])
	var battleField = BattlefieldState.new("map.json")
	
	var matchNode = matchController.new(matchState, battleField)
	matchNode.name = "Match_%d" % _next_match_id
	matchNode.add_child(matchState)
	matchNode.add_child(battleField)
	get_parent().add_child(matchNode)
	peer_to_match[peerId1] = matchState.matchId
	peer_to_match[peerId2] = matchState.matchId
	matches[_next_match_id] = matchNode
	_next_match_id += 1
	Network.Match.match_created.rpc_id(peerId1)
	Network.Match.match_created.rpc_id(peerId2)

# signals handlers
func _on_player_connect(peer_id: int) -> void:
	var matchId: int = peer_to_match[peer_id]
	var matchCtl: matchController = matches[matchId]
	matchCtl.handle_connect(peer_id)
	
func _on_player_disconnect(peed_id: int) -> void:
	var matchId: int = peer_to_match[peed_id]
	var matchCtl: matchController = matches[matchId]
	matchCtl.handle_disconnect(peed_id)

func _on_connect_match_requested(peer_id: int) -> void:
	var matchId: int = peer_to_match[peer_id]
	var matchCtl: matchController = matches[matchId]
	Network.Match.init(matchId, matchCtl.battlefield.mapName, matchCtl.matchState.player_ids)
