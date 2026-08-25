extends Node3D

@export var roll_duration: float = 1.2
@export var min_spins: int = 3
@export var max_spins: int = 5

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

func _on_resolve_combat_result(result: CombatResult) -> void:
	roll_dice(result.rolled_dices)

func roll_dice(results: Array[enums.RolledDice]) -> void:
	if rolling:
		return

	rolling = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)

	var dice: Array[Node] = []
	var result_index := 0
	var dies = $Dies
	
	print("roll results: ", results)

	for die in dies.get_children():

		if result_index >= results.size():
			break

		dice.append(die)

		var result: enums.RolledDice = results[result_index]
		var face: int = result_to_face[result]

		result_index += 1

		var target_rotation: Vector3 = face_rotations[face]

		var spins := randi_range(min_spins, max_spins)

		var spin_x := TAU * spins
		var spin_y := TAU * spins
		var spin_z := TAU * spins

		if randf() < 0.5:
			spin_x *= -1.0

		if randf() < 0.5:
			spin_y *= -1.0

		if randf() < 0.5:
			spin_z *= -1.0

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
		)

	await tween.finished

	# Snap each die to its exact result.
	result_index = 0

	for die in dice:
		var result: enums.RolledDice = results[result_index]
		var face: int = result_to_face[result]

		die.rotation = face_rotations[face]

		result_index += 1

	rolling = false
