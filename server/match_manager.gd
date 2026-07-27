extends Node
class_name MatchManager
var _next_match_id: int = 0
var peer_to_match: Dictionary[int, int] = {}
var matches: Dictionary[int, matchController] = {}
@onready var card_database: Node = $"../CardDatabase"

func _ready() -> void:
	Network.Match.connect_match_requested.connect(_on_player_connect)
	Network.Match.update_client_match_change_requested.connect(_on_client_match_state_change)
	Network.Match.sync_requested.connect(_on_sync_match_state)
	# Action signals
	Network.Actions.play_card_requested.connect(_on_play_card)
	Network.Actions.issue_order_requested.connect(_on_issue_order)
	Network.Actions.execute_orders_requested.connect(_on_execute_orders)
	Network.Actions.draw_card_requested.connect(_on_draw_card)

func create_new_match(peerId1: int, peerId2: int) -> void:
	print("Call to create new match")
	var matchState = MatchState.new()
	matchState.initialize(_next_match_id, [peerId1, peerId2])
	var battleField = BattlefieldState.new("map.json")
	var deckManager = DeckManager.new(peerId1, peerId2)
	
	var matchNode = matchController.new(matchState, battleField, deckManager)
	matchNode.name = "Match_%d" % _next_match_id
	matchNode.add_child(matchState)
	matchNode.add_child(battleField)
	matchNode.add_child(deckManager)
	get_parent().add_child(matchNode)
	peer_to_match[peerId1] = matchState.matchId
	peer_to_match[peerId2] = matchState.matchId
	matches[_next_match_id] = matchNode
	_next_match_id += 1
	Network.Match.match_created.rpc_id(peerId1)
	Network.Match.match_created.rpc_id(peerId2)

func get_match(peer_id: int) -> matchController:
	var matchId: int = peer_to_match[peer_id]
	var matchCtl: matchController = matches[matchId]
	return matchCtl

# signals handlers
func _on_sync_match_state(peer_id: int, snapshot: Dictionary):
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.matchState.sync_with_server(snapshot)

func _on_player_connect(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_connect(peer_id)
	
func _on_player_disconnect(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_disconnect(peer_id)

func _on_connect_match_requested(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	Network.Match.init(matchCtl.matchState.matchId, matchCtl.battlefield.mapName, matchCtl.matchState.player_ids)

func _on_client_match_state_change(peer_id: int, state: MatchState.STATE):
	print("Client state change")
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_client_state_change(peer_id, state)

# player actions
func _on_play_card(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(MatchState.TURN_PHASE.PLAY_CARD):
		return
	pass

func _on_issue_order(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(MatchState.TURN_PHASE.ISSUE_ORDERS):
		return

func _on_execute_orders(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(MatchState.TURN_PHASE.EXECUTE_ORDERS):
		return

func _on_draw_card(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(MatchState.TURN_PHASE.DRAW_CARD):
		return
	matchCtl.deckManager.draw_card(peer_id)
