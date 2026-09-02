extends Node
@onready var renderGameBoard = preload("res://client/battlefield/battlefield.tscn")
@export var loader: Loader
var battlefieldRenderer: Node2D
var battlefield: BattlefieldState
var unitManager: ClientUnitManager
@export var client: WebClient
var initial_snapshot: Dictionary

func _ready() -> void:
	Network.Match.init_match_requested.connect(initialize_game)
	Network.Match.start_game_requested.connect(start_game)
	assert(WebClient != null)

func initialize_game(snapshot: Dictionary):
	print("client(%d) initializing game" % multiplayer.get_unique_id())
	client.players_connected = true
	self.initial_snapshot = snapshot
	add_child(MatchState.new(snapshot.match_state if snapshot.has("match_state") else {}))
	battlefield = BattlefieldState.new(snapshot.map_name)
	add_child(battlefield)
	battlefieldRenderer = renderGameBoard.instantiate()
	unitManager = ClientUnitManager.new(battlefield)
	add_child(unitManager)
	add_child(ClientHandState.new())
	battlefieldRenderer.ready.connect(_ready_to_initialize)
	unitManager.initialize(battlefieldRenderer.unit_container, snapshot)
	client.initialized = true
	Network.Match.client_ready.rpc_id(1)
	
func start_game() -> void:
	client.players_ready = true

func _ready_to_initialize() -> void:
	battlefieldRenderer.initialize(initial_snapshot)
	initial_snapshot.clear()
