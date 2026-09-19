class_name UnitFigure
extends Node2D

@export var anim_sprite: AnimatedSprite2D
@export var base_sprite: Sprite2D

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
