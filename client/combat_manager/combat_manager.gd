extends Node

@export var dice_roller: Node3D
@export var player_controller: Node
@onready var unit_manager: ClientUnitManager = $"../../UnitManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result_requested)

func _on_resolve_combat_result_requested(result: CombatResult) -> void:
	player_controller.attacked_unit_highlight_layer.clear()
	var target_id: int = result.unit_ids[result.target]
	var target_unit: Unit = unit_manager.get_unit_by_id(target_id)
	if not target_unit:
		push_error("No target unit id found from CombatResult: ", target_id)
		return
	player_controller.attacked_unit_highlight_layer.highlight_cell(target_unit.hex_coord)
	player_controller.attack_in_progress = true
	target_unit.is_in_combat = true
	dice_roller.roll_dice(result.rolled_dices)
	await dice_roller.dice_roll_finished
	await get_tree().create_timer(0.2).timeout
	target_unit.hit_point -= result.dmg
	target_unit.is_in_combat = false
	player_controller.attack_in_progress = false
	player_controller.attacked_unit_highlight_layer.clear()
