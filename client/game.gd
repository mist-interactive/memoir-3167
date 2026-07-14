extends Node
@onready var renderGameBoard = preload("res://client/battlefield/battlefield.tscn")
const LoaderScene = preload("res://client/ui/loading.tscn")
@export var loader: Loader
var battlefieldRenderer: Node2D
@export var menu: Node2D

func _ready() -> void:
	Network.Match.init_match_requested.connect(create_new_match)

func create_new_match(matchId: int, mapName: String, player_ids: Array[int]):
	menu.hide()
	await loader.stage("Initializing battlefield...", func(): add_child(BattlefieldState.new(mapName))) \
	.stage("Initializing matchstate...", func(): add_child(MatchState.new())) \
	.stage("Loading map...", func(): battlefieldRenderer = renderGameBoard.instantiate(); Network.Match.update_client_match_state.rpc(MatchState.STATE.READY)) \
	.stage("Waiting oponents to ready up...", func(): await loader.wait_untill(func(): return get_child(1).state == MatchState.STATE.READY)) \
	.run()
	add_child(battlefieldRenderer)
