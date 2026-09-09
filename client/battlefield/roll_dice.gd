extends Node3D

@export var roll_duration: float = 1.8
@export var min_spins: int = 6
@export var max_spins: int = 10

var rolling := false

var face_rotations := {
	1: Vector3(0, 0, 0), # FLAG
	2: Vector3(deg_to_rad(90), 0, 0), # INFANTRY
	3: Vector3(deg_to_rad(180), 0, 0), # TANK
	4: Vector3(0, deg_to_rad(-90), 0), # INFANTRY
	5: Vector3(deg_to_rad(-90), deg_to_rad(90), 0), # ALL
	6: Vector3(deg_to_rad(-90), 0, 0) # MISS
}

var result_to_face := {
	enums.RolledDice.INFANTRY_1: 2,
	enums.RolledDice.INFANTRY_2: 4,
	enums.RolledDice.ALL: 5,
	enums.RolledDice.ARMOR: 3,
	enums.RolledDice.RETREAT: 1,
	enums.RolledDice.MISS: 6,
}


func _ready() -> void:
	Network.Actions.resolve_combat_result_requested.connect(_on_resolve_combat_result)
	randomize()

	# Hide all dice initially.
	for die in $Dice.get_children():
		die.visible = false


func _on_resolve_combat_result(result: CombatResult) -> void:
	roll_dice(result.rolled_dices)


func roll_dice(results: Array[enums.RolledDice]) -> void:
	if rolling or results.is_empty():
		return

	rolling = true

	var dies := $Dice.get_children()
	var dice: Array[Node3D] = []

	# Hide all dice before the roll.
	for die in dies:
		die.visible = false

	# Only show as many dice as we are rolling.
	for i in range(min(results.size(), dies.size())):
		var die: Node3D = dies[i]
		die.visible = true
		dice.append(die)

	var tween := create_tween()
	tween.set_parallel(true)

	for i in range(dice.size()):
		var die: Node3D = dice[i]
		var result: enums.RolledDice = results[i]
		var face: int = result_to_face[result]

		var target_rotation: Vector3 = face_rotations[face]

		# Start from the current Euler rotation.
		var start_rotation := die.rotation

		var spins := randi_range(min_spins, max_spins)

		var spin_x := TAU * spins
		var spin_y := TAU * spins
		var spin_z := TAU * spins

		# Randomize spin direction on each axis.
		if randf() < 0.5:
			spin_x *= -1.0

		if randf() < 0.5:
			spin_y *= -1.0

		if randf() < 0.5:
			spin_z *= -1.0

		# Add the requested number of full rotations to the
		# final Euler orientation.
		var final_rotation := Vector3(
			target_rotation.x + spin_x,
			target_rotation.y + spin_y,
			target_rotation.z + spin_z
		)

		tween.tween_property(
			die,
			"rotation",
			final_rotation,
			roll_duration
		).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	await tween.finished

	# Snap every die to the exact Euler orientation.
	for i in range(dice.size()):
		var die: Node3D = dice[i]
		var result: enums.RolledDice = results[i]
		var face: int = result_to_face[result]

		die.rotation = face_rotations[face]

	rolling = false
