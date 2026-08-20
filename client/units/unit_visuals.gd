@tool

class_name UnitVisuals

extends RefCounted

static var TEXTURE_MAP: Dictionary = {
	1: {
		enums.UnitType.INFANTRY: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
		enums.UnitType.TANK: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
		enums.UnitType.ARTILLERY: preload("res://assets/sprites/units/artillery_sprite_sheet.png")
	},
	2: {
		enums.UnitType.INFANTRY: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
		enums.UnitType.TANK: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
		enums.UnitType.ARTILLERY: preload("res://assets/sprites/units/artillery_sprite_sheet.png")
	}
}
static var scale: Vector2 = Vector2(6, 6)
static var tank1: PackedScene = preload("res://client/units/Tanks/Tank_1.tscn")
static var tank2: PackedScene = preload("res://client/units/Tanks/Tank_2.tscn")

static func apply_unit_visuals(sprite: Sprite2D, owner_id: int, unit_type: int) -> void:
	if not TEXTURE_MAP.has(owner_id):
		push_warning("Invalid owner_id: ", owner_id)
		return
	if not TEXTURE_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type: ", unit_type)
		return
	sprite.scale = scale
	if unit_type == enums.UnitType.INFANTRY:
		sprite.texture = TEXTURE_MAP[owner_id][unit_type]
		sprite.hframes = 4
		sprite.vframes = 5
		if owner_id == 1:
			sprite.frame = 0
		if owner_id == 2:
			sprite.frame = 16
	if unit_type == enums.UnitType.TANK:
		sprite.texture = null
		if owner_id == 1:
			sprite.get_parent().add_child(tank2.instantiate())
		else:
			sprite.get_parent().add_child(tank1.instantiate())		
	if unit_type == enums.UnitType.ARTILLERY:
		sprite.texture = TEXTURE_MAP[owner_id][unit_type]
		sprite.hframes = 6
		sprite.vframes = 5
		if owner_id == 1:
			sprite.frame = 0
		if owner_id == 2:
			sprite.frame = 24
