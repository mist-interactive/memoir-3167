# battlefield.gd (Attached to the root Node2D of battlefield.tscn)
extends Node2D

@export var unit_container: Node
@onready var match_state: MatchState = $"../matchState"
@onready var hand_state: ClientHandState = $"../HandState"
signal game_loaded(phaes: enums.TurnPhase)

func _ready() -> void:
	pass

func initialize(snapshot: Dictionary) -> void:
	hand_state.initialize(snapshot.hand_state if snapshot.has("hand_state") else {})
	await get_tree().create_timer(0.5).timeout
	if match_state.state != MatchState.STATE.PAUSED:
		game_loaded.emit(match_state.phase)
