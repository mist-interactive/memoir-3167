extends Node

@export var dice_roller: Node3D
@onready var unit_manager: ClientUnitManager = $"../../UnitManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result_requested)

func _on_resolve_combat_result_requested(result: CombatResult) -> void:
	var target_id: int = result.unit_ids[result.target]
	var target_unit: Unit = unit_manager.get_unit_by_id(target_id)
	if not target_unit:
		push_error("No target unit id found from CombatResult: ", target_id)
		return
	target_unit.is_in_combat = true
	dice_roller.roll_dice(result.rolled_dices)
	await dice_roller.dice_roll_finised
	await get_tree().create_timer(0.2).timeout
	target_unit.hit_point -= result.dmg
	if result.dmg > 0:
		target_unit.explosion_animation.visible = true
		target_unit.explosion_animation.play("explosion")
		await target_unit.explosion_animation.animation_finished
		target_unit.explosion_animation.visible = false
	UnitVisuals.update_unit_visuals(target_unit)
	if target_unit.hit_point <= 0:
		_handle_unit_death(target_unit)
	else:
		target_unit.is_in_combat = false
	pass

func _handle_unit_death(unit: Unit) -> void:
	
	unit.queue_free()
