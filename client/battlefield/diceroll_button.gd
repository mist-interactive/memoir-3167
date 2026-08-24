extends Button

func _on_pressed() -> void:
	var amount_to_roll := randi_range(1, 6)
	var to_roll: Array[enums.RolledDice] = Dice.roll(amount_to_roll)
	$"../SubViewport/Node3D".roll_to(to_roll)
