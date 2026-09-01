extends Node
@onready var renderGameBoard = preload("res://client/battlefield/battlefield.tscn")
@export var loader: Loader
var battlefieldRenderer: Node2D
var battlefield: BattlefieldState
var unitManager: ClientUnitManager

@export var menu: Node2D

func _ready() -> void:
	Network.Match.init_match_requested.connect(join_game)

func join_game(snapshot: Dictionary):
	menu.hide()
	loader.stage("Initializing battlefield...", func(): battlefield = BattlefieldState.new(snapshot.map_name); add_child(battlefield))
	match snapshot.state:
		MatchState.STATE.INITIALIZE_BOARD, MatchState.STATE.INITIALIZING:
			loader.stage("Initializing matchstate...", func(): add_child(MatchState.new())) \
			.stage("Initializing handstate...", func(): add_child(ClientHandState.new())) \
			.stage("Loading map...", func(): battlefieldRenderer = renderGameBoard.instantiate(); Network.Match.update_client_match_state.rpc_id(1, MatchState.STATE.READY)) \
			.stage("Initializing units...", func(): unitManager = ClientUnitManager.new(battlefield); add_child(unitManager)) \
			.stage("Waiting oponents to ready up...", func(): await loader.wait_untill(func(): return get_child(1).state == MatchState.STATE.INITIALIZE_BOARD))
		MatchState.STATE.IN_PROGRESS, MatchState.STATE.PAUSED:
			# [todo] shoud till match resumes back
			loader.stage("Initializing matchstate...", func(): add_child(MatchState.new(snapshot.match_state))) \
			.stage("Initializing handstate...", func(): add_child(ClientHandState.new())) \
			.stage("Loading map...", func(): battlefieldRenderer = renderGameBoard.instantiate(); Network.Match.update_client_match_state.rpc_id(1, MatchState.STATE.READY)) \
			.stage("Initializing units...", func(): unitManager = ClientUnitManager.new(battlefield); add_child(unitManager))
			#.stage("Waiting oponents to ready up...", func(): await loader.wait_untill(func(): return get_child(1).state == MatchState.STATE.INITIALIZE_BOARD))

	await loader.run()
	add_child(battlefieldRenderer)
	unitManager.initialize(battlefieldRenderer.unit_container, snapshot)
	match snapshot.state:
		MatchState.STATE.INITIALIZE_BOARD, MatchState.STATE.INITIALIZING:
			Network.Match.update_client_match_state.rpc_id(1, MatchState.STATE.INITIALIZE_BOARD)
		MatchState.STATE.IN_PROGRESS, MatchState.STATE.PAUSED:
			Network.Match.update_client_match_state.rpc_id(1, MatchState.STATE.READY)
