extends Node
@onready var renderGameBoard = preload("res://client/battlefield/battlefield.tscn")
@export var loader: Loader
var battlefieldRenderer: Node2D
var local_hand: PlayerHandModel
@export var menu: Node2D

func _ready() -> void:
	Network.Match.init_match_requested.connect(create_new_match)
	initialize_player_hand_model()

func create_new_match(matchId: int, mapName: String, player_ids: Array[int]):
	menu.hide()
	await loader.stage("Initializing battlefield...", func(): add_child(BattlefieldState.new(mapName))) \
	.stage("Initializing matchstate...", func(): add_child(MatchState.new())) \
	.stage("Loading map...", func(): battlefieldRenderer = renderGameBoard.instantiate(); Network.Match.update_client_match_state.rpc_id(1, MatchState.STATE.READY)) \
	.stage("Waiting oponents to ready up...", func(): await loader.wait_untill(func(): return get_child(1).state == MatchState.STATE.READY)) \
	.run()
	add_child(battlefieldRenderer)
	var battlefield_node = renderGameBoard.instantiate()
	add_child(battlefield_node)
	if battlefield_node.has_method("setup_hand_ui"):
		battlefield_node.setup_hand_ui(local_hand)

# from usva vv
# func create_new_match(battleField: BattlefieldState, matchState: MatchState) -> void:
# 	print("DEBUG: game.gd local_hand ID: ", local_hand.get_instance_id())
# 	print("newMatch: ", matchState.matchId)
# 	add_child(battleField)
# 	add_child(matchState)
# 	var battlefield_node = renderGameBoard.instantiate()
# 	add_child(battlefield_node)
# 	if battlefield_node.has_method("setup_hand_ui"):
# 		battlefield_node.setup_hand_ui(local_hand)
	

func initialize_player_hand_model() -> void:
	local_hand = PlayerHandModel.new()
	Network.Card.active_hand_model = local_hand
	Network.Card.local_card_received.connect(local_hand.add_card)
	Network.Card.local_card_removed.connect(local_hand.remove_card)
