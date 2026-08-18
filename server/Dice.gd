extends RefCounted
class_name Dice

static func roll(num_of_dice: int) -> Array[enums.RolledDice]:
	var rolled: Array[enums.RolledDice]
	var num_rolled: int = 0
	while num_rolled < num_of_dice:
		var n: int = randi_range(0, 5)
		if n < enums.RolledDice.MISS:
			rolled.append(n)
		else:
			rolled.append(enums.RolledDice.MISS)
		num_rolled += 1
	return rolled
