@tool

class_name UnitVisuals

extends RefCounted

static var TEXTURE_MAP: Dictionary = {
	1: {
		GameEnums.UnitType.INFANTRY: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
		GameEnums.UnitType.TANK: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
		GameEnums.UnitType.ARTILLERY: preload("res://assets/sprites/units/artillery_sprite_sheet.png")
	},
	2: {
		GameEnums.UnitType.INFANTRY: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
		GameEnums.UnitType.TANK: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
		GameEnums.UnitType.ARTILLERY: preload("res://assets/sprites/units/artillery_sprite_sheet.png")
	}
}
static var scale: Vector2 = Vector2(6, 6)

static func apply_unit_visuals(sprite: Sprite2D, owner_id: int, unit_type: int) -> void:
	if not TEXTURE_MAP.has(owner_id):
		push_warning("Invalid owner_id: ", owner_id)
		return
	if not TEXTURE_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type: ", unit_type)
		return
	sprite.texture = TEXTURE_MAP[owner_id][unit_type]
	sprite.scale = scale
	if unit_type == GameEnums.UnitType.INFANTRY:
		sprite.hframes = 4
		sprite.vframes = 5
		if owner_id == 1:
			sprite.frame = 0
		if owner_id == 2:
			sprite.frame = 16
	if unit_type == GameEnums.UnitType.TANK:
		sprite.hframes = 5
		sprite.vframes = 5
		if owner_id == 1:
			sprite.frame = 0
		if owner_id == 2:
			sprite.frame = 20
	if unit_type == GameEnums.UnitType.ARTILLERY:
		sprite.hframes = 6
		sprite.vframes = 5
		if owner_id == 1:
			sprite.frame = 0
		if owner_id == 2:
			sprite.frame = 24
