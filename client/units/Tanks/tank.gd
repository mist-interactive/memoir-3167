extends Node2D
@onready var anni:AnimatedSprite2D = $AnimatedSprite2D

func scan() -> void:
	anni.play("scan")

func shoot() -> void:
	anni.play("shoot")
	var timer = get_tree().create_timer(2)
	await timer.timeout
	idle()
	
func idle() -> void:
	anni.play("default")
