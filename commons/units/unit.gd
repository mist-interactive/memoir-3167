class_name Unit
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer


@export var owner_id: int = 1
@export var hex_coord: Vector2i = Vector2i.ZERO:
	set(new_coord):
		if hex_coord == new_coord:
			return
		UnitManager.move_unit(self, hex_coord, new_coord)
		hex_coord = new_coord
		if is_inside_tree():
			_animate_to_hex(new_coord)

var is_selected: bool = false

func _ready() -> void:
	UnitManager.add_unit(self, hex_coord)
	pass

func _animate_to_hex(target_coord: Vector2i) -> void:
	# Calculate where this hex actually is on the screen
	# (Assuming you have a HexGrid autoload with your math)
	var target_pixel_pos = HexGrid.offset_to_pixel(target_coord)
	
	# Smoothly slide the unit over 0.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "position", target_pixel_pos, 0.5).set_trans(Tween.TRANS_SINE)

func _exit_tree() -> void:
	UnitManager.remove_unit(hex_coord)
