# battlefield.gd (Attached to the root Node2D of battlefield.tscn)
extends Node2D

@export var unit_container: Node
@onready var hand_state: ClientHandState = $"../HandState"

func _ready() -> void:
	pass

func initialize(snapshot: Dictionary) -> void:
	hand_state.initialize(snapshot.hand_state if snapshot.has("hand_state") else {})
