extends Node2D
@onready var anni:AnimatedSprite2D = $AnimatedSprite2D
var bullet: PackedScene = preload("res://client/units/Tanks/bullet.tscn")
# v = 
func scan() -> void:
	anni.play("scan")

func shoot(pos: Vector2) -> void:
	var bullet: Node2D = load_bullet(pos)
	anni.play("shoot")
	get_tree().current_scene.add_child(bullet)

func load_bullet(target: Vector2) -> Node2D:
	var bullet: Node2D = bullet.instantiate()
	bullet.dir = (target - global_position).normalized()
	bullet.position = global_position
	bullet.final_pos = target
	return bullet

func idle() -> void:
	anni.play("default")
