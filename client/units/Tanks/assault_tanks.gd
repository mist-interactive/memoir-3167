extends Node2D
@onready var tanks: Array[Node2D] = [$left, $mid, $right]

func scan(num: int = 3) -> void:
	for i in range(num):
		tanks[i].scan()

func attack(num: int) -> void:
	var i: int = 0
	while i < 3:
		if i < num:
			tanks[i].shoot()
		else:
			tanks[i].idle()
		i += 1

func idle() -> void:
	for i in range(3):
		tanks[i].idle()
