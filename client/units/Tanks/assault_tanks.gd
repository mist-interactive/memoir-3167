extends Node2D
@onready var tanks: Array[Node2D] = [$left, $mid, $right]
var cooldown: int = 1.5
func scan(num: int = 3) -> void:
	for i in range(num):
		tanks[i].scan()

func attack(pos: Vector2, num: int) -> void:
	var i: int = 0
	while i < 3:
		if i < num:
			var timer = get_tree().create_timer(cooldown)
			tanks[i].shoot(pos)
			await timer.timeout
			tanks[i].idle()
		else:
			var timer = get_tree().create_timer(cooldown)
			await timer.timeout
			tanks[i].idle()
		i += 1

func idle() -> void:
	for i in range(3):
		tanks[i].idle()
