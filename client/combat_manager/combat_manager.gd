extends Node

@export var dice_roller: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result_requested)

func _on_resolve_combat_result_requested(result: CombatResult) -> void:
	dice_roller.roll_dice(result.rolled_dices)
	await dice_roller.dice_roll_finished
	await get_tree().create_timer(1.0).timeout
	
	pass
