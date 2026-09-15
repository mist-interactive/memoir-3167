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
		if not _is_initialized:
			position = HexGrid.offset_to_pixel(new_coord)
			_is_initialized = true
		elif not _move_tween or not _move_tween.is_running():
			position = HexGrid.offset_to_pixel(new_coord)

var uuid: int = -1
var type: enums.UnitType = enums.UnitType.INFANTRY
var actions: enums.UnitActions = enums.UnitActions.NONE
var hit_point: int = -1
var _is_initialized: bool = false
var _move_tween: Tween
var num_of_retreat: int = -1

func _ready() -> void:
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func setup(new_owner: enums.Side, new_type: enums.UnitType, new_uuid:int, new_hex_coord: Vector2i) -> void:
	owner_id = new_owner
	type = new_type
	uuid = new_uuid
	hex_coord = new_hex_coord
	hit_point = UnitDatabase.get_stats(type).max_health
	UnitVisuals.apply_unit_visuals(sprite, owner_id, type)

func move_along_path(path: Array[Vector2i]) -> void:
	if path.is_empty():
		return
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween()
	for coord in path:
		var target_pixel_pos: Vector2 = HexGrid.offset_to_pixel(coord)
		_move_tween.tween_property(self, "position", target_pixel_pos, 0.25).set_trans(Tween.TRANS_LINEAR)
	_move_tween.finished.connect(_on_move_finished.bind(path.back()))

func _on_move_finished(final_coord: Vector2i) -> void:
	hex_coord = final_coord

func is_my_unit(side: enums.Side) -> bool:
	return owner_id == side

func sync_with_snapshot(snapshot: Dictionary) -> void:
	self.uuid = snapshot.uuid
	self.type = snapshot.type
	self.owner_id = snapshot.owner_id
	self.hit_point = snapshot.hit_point
	self.hex_coord = snapshot.hex_coord
	self.actions = snapshot.actions
	self.num_of_retreat = snapshot.num_of_retreat

func _exit_tree() -> void:
	pass

func is_selected() -> bool:
	return (actions & enums.UnitActions.IS_SELECTED) != 0

func can_move() -> bool:
	return (actions & enums.UnitActions.CAN_MOVE) != 0

func can_attack() -> bool:
	return (actions & enums.UnitActions.CAN_ATTACK) != 0

func can_retreat() -> bool:
	return (actions & enums.UnitActions.CAN_RETREAT) != 0
