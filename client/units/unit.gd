class_name Unit
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var owner_id: int = 1
@export var hex_coord: Vector2i = Vector2i.ZERO:
	set(new_coord):
		if hex_coord == new_coord:
			return
		hex_coord = new_coord
		if is_initialized:
			_animate_to_hex(new_coord)
		else:
			is_initialized = true
			position = HexGrid.offset_to_pixel(new_coord) + visual_offset

var is_initialized: bool = false
var uuid: int = -1
var type: enums.UnitType = enums.UnitType.INFANTRY
var is_selected: bool = false
var visual_offset: Vector2:
	get:
		return Vector2(HexMetrics.half_width, HexMetrics.half_height)

func _ready() -> void:
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func setup(new_owner: int, new_type: GameEnums.UnitType, new_uuid:int, new_hex_coord: Vector2i) -> void:
	owner_id = new_owner
	type = new_type
	uuid = new_uuid
	hex_coord = new_hex_coord
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func _animate_to_hex(target_coord: Vector2i) -> void:
	# Calculate where this hex actually is on the screen
	# (Assuming you have a HexGrid autoload with your math)
	var target_pixel_pos = HexGrid.offset_to_pixel(target_coord) + visual_offset

	# Smoothly slide the unit over 0.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "position", target_pixel_pos, 0.5).set_trans(Tween.TRANS_SINE)

func sync_with_snapshot(snapshot: Dictionary) -> void:
	self.uuid = snapshot.uuid
	self.hex_coord = snapshot.hex_coord
	self.type = snapshot.type
	self.owner_id = snapshot.owner_id

func _exit_tree() -> void:
	pass
