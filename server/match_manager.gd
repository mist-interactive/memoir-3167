extends Node
class_name MatchManager
var _next_match_id: int = 0
var peer_to_match: Dictionary[int, int] = {}
var uuid_to_peer: Dictionary[int, int] = {}
var matches: Dictionary[int, matchController] = {}
@onready var card_database: Node = $"../CardDatabase"

func _ready() -> void:
	Network.Match.connect_match_requested.connect(_on_player_connect)
	Network.Match.update_client_match_change_requested.connect(_on_client_match_state_change)
	Network.Match.sync_requested.connect(_on_sync_match_state)
	# Action signals
	Network.Actions.draw_hand_requested.connect(_on_draw_hand)
	Network.Actions.play_card_requested.connect(_on_play_card)
	Network.Actions.select_unit_requested.connect(_on_select_unit)
	Network.Actions.move_unit_requested.connect(_on_move_unit)
	Network.Actions.attack_unit_requested.connect(_on_attack_unit)
	Network.Actions.draw_card_requested.connect(_on_draw_card)
	Network.Actions.continue_to_next_phase_requested.connect(_on_continue_to_next_phase_requested)

func create_new_match(peerId1: int, peerId2: int, uuid1: int, uuid2: int) -> void:
	print("Call to create new match")
	var matchNode = matchController.new(_next_match_id, peerId1, peerId2)
	get_parent().add_child(matchNode)
	peer_to_match[peerId1] = _next_match_id
	peer_to_match[peerId2] = _next_match_id
	uuid_to_peer[uuid1] = peerId1
	uuid_to_peer[uuid2] = peerId2
	matches[_next_match_id] = matchNode
	_next_match_id += 1
	Network.Match.match_created.rpc_id(peerId1)
	Network.Match.match_created.rpc_id(peerId2)

func reconnect(peer_id: int, uuid: int) -> void:
	var old_peer_id: int = uuid_to_peer[uuid]
	var matchCtl: matchController = get_match(old_peer_id)
	peer_to_match[peer_id] = matchCtl.matchState.matchId
	matchCtl.peer_reconnected(peer_id, old_peer_id)
	var units: Array[Dictionary]
	for unit: UnitData in matchCtl.unit_manager.units_by_id.values():
		units.append({
			"owner_id": unit.owner_id,
			"uuid": unit.uuid,
			"type": unit.type,
			"coord": unit.hex_coord
		})
	var snapshot: Dictionary = {
		"state": matchCtl.matchState.state,
		"match_id": matchCtl.matchState.matchId,
		"map_name": matchCtl.battlefield.mapName,
		"units": units
	}
	Network.Match.init.rpc_id(peer_id, snapshot)


func get_match(peer_id: int) -> matchController:
	var matchId: int = peer_to_match[peer_id]
	var matchCtl: matchController = matches[matchId]
	return matchCtl

func get_match_by_uuid(uuid: int) -> matchController:
	return get_match(uuid_to_peer[uuid])

# signals handlers
func _on_sync_match_state(peer_id: int, snapshot: Dictionary):
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.matchState.sync_with_server(snapshot)

func _on_player_connect(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_connect(peer_id)
	var snapshot: Dictionary = {
		"state": matchCtl.matchState.state,
		"match_id": matchCtl.matchState.matchId,
		"map_name": matchCtl.battlefield.mapName
	}
	Network.Match.init.rpc_id(peer_id, snapshot)

func _on_player_disconnect(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_disconnect(peer_id)

func _on_connect_match_requested(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	var snapshot: Dictionary = {
		"state": matchCtl.matchState.state,
		"match_id": matchCtl.matchState.matchId,
		"map_name": matchCtl.battlefield.mapName
	}
	Network.Match.init.rpc_id(peer_id, snapshot)

func _on_client_match_state_change(peer_id: int, state: MatchState.STATE):
	print("Client state change")
	var matchCtl: matchController = get_match(peer_id)
	matchCtl.handle_client_state_change(peer_id, state)

# player actions
func _on_continue_to_next_phase_requested(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	matchCtl.go_next_phase(side)
func _on_draw_hand(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	#if !matchCtl.isInProgress() || !matchCtl.isPhase(enums.TurnPhase.DRAW_HAND):
		#return
	print("Hand draw ", peer_id)
	var side: enums.Side = matchCtl.get_side(peer_id)
	matchCtl.deckManager.draw_hand(side, matchCtl.sides_peer_ids)
	for hand: HandState in matchCtl.deckManager.player_hands.values():
		if hand.card_ids.size() == 0:
			return
	matchCtl.matchState.phase = enums.TurnPhase.PLAY_CARD

func _on_play_card(peer_id: int, instance_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(enums.TurnPhase.PLAY_CARD):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	print("Player requested to play a card ", peer_id, instance_id)
	if matchCtl.deckManager.play_card(side, instance_id, matchCtl.sides_peer_ids):
		matchCtl.matchState.phase = enums.TurnPhase.SELECT

func _on_select_unit(peer_id: int, unit_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id):
		return
	if !matchCtl.validate_unit_selection(unit_id):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	matchCtl.unit_manager.select_unit(side, unit_id, matchCtl.deckManager.get_card())

func _on_move_unit(peer_id: int, unit_id: int, destination: Vector2i) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(enums.TurnPhase.MOVE):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	if matchCtl.unit_manager.move_unit_request(side, unit_id, destination, matchCtl.sides_peer_ids):
		if matchCtl.unit_manager.moved_units_ids.size() == matchCtl.unit_manager.selected_units_ids.size():
			matchCtl.matchState.phase = enums.TurnPhase.ATTACK
			matchCtl.unit_manager.next_phase(enums.TurnPhase.ATTACK)

func _on_attack_unit(peer_id: int, unit_id: int, target_unit_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(enums.TurnPhase.ATTACK):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	if matchCtl.unit_manager.attack_unit(side, unit_id, target_unit_id, matchCtl.sides_peer_ids):
		if matchCtl.unit_manager.attacked_units_ids.size() == matchCtl.unit_manager.selected_units_ids.size():
			matchCtl.unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
			matchCtl.matchState.phase = enums.TurnPhase.PLAY_CARD
			matchCtl.matchState.current_turn = enums.Side.RED if side == enums.Side.GREEN else enums.Side.GREEN

func _on_draw_card(peer_id: int) -> void:
	var matchCtl: matchController = get_match(peer_id)
	if !matchCtl.isInProgress() || !matchCtl.isPlayerTurn(peer_id) || !matchCtl.isPhase(enums.TurnPhase.DRAW_CARD):
		return
	var side: enums.Side = matchCtl.get_side(peer_id)
	if matchCtl.deckManager.draw_card(side, matchCtl.sides_peer_ids):
		matchCtl.matchState.phase = enums.TurnPhase.PLAY_CARD
		matchCtl.unit_manager.next_phase(enums.TurnPhase.PLAY_CARD)
