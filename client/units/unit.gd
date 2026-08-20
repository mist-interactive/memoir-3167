class_name Unit
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var owner_id: enums.Side = enums.Side.NONE
@export var hex_coord: Vector2i = Vector2i.ZERO:
	set(new_coord):
		if hex_coord == new_coord:
			return
		hex_coord = new_coord
		if is_initialized:
			_animate_to_hex(new_coord)
		else:
			is_initialized = true
			position = HexGrid.offset_to_pixel(new_coord)

var is_initialized: bool = false
var uuid: int = -1
var type: enums.UnitType = enums.UnitType.INFANTRY
var hit_point: int = -1
var is_selected: bool = false

func _ready() -> void:
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func setup(new_owner: enums.Side, new_type: GameEnums.UnitType, new_uuid:int, new_hex_coord: Vector2i) -> void:
	owner_id = new_owner
	type = new_type
	uuid = new_uuid
	hex_coord = new_hex_coord
	hit_point = UnitDatabase.get_stats(type).max_health
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func _animate_to_hex(target_coord: Vector2i) -> void:
	# Calculate where this hex actually is on the screen
	# (Assuming you have a HexGrid autoload with your math)
	var target_pixel_pos = HexGrid.offset_to_pixel(target_coord)

	# Smoothly slide the unit over 0.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "position", target_pixel_pos, 0.5).set_trans(Tween.TRANS_SINE)

func is_my_unit(side: enums.Side) -> bool:
	return owner_id == side

func sync_with_snapshot(snapshot: Dictionary) -> void:
	self.uuid = snapshot.uuid
	self.hex_coord = snapshot.hex_coord
	self.type = snapshot.type
	self.owner_id = snapshot.owner_id
	self.hit_point = snapshot.hit_point

func _exit_tree() -> void:
	pass
