@tool

class_name UnitVisuals

extends RefCounted

static var TEXTURE_MAP: Dictionary = {
	1: {
		enums.UnitType.INFANTRY: preload("res://assets/sprites/units/allied_infantry_idle_48x48.png"),	
		enums.UnitType.TANK: preload("res://assets/sprites/units/allied_armor_idle_96x96.png"),	
		enums.UnitType.ARTILLERY: preload("res://assets/sprites/units/allied_artillery_idle_96x96.png")
	},
	2: {
		enums.UnitType.INFANTRY: preload("res://assets/sprites/units/axis_infantry_idle_48x48.png"),	
		enums.UnitType.TANK: preload("res://assets/sprites/units/axis_armor_idle_96x96.png"),	
		enums.UnitType.ARTILLERY: preload("res://assets/sprites/units/axis_artillery_96x96.png")
	}
}
static var scale: Vector2 = Vector2(1, 1)

static func apply_unit_visuals(sprite: Sprite2D, owner_id: int, unit_type: int) -> void:
	if not TEXTURE_MAP.has(owner_id):
		push_warning("Invalid owner_id: ", owner_id)
		return
	if not TEXTURE_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type: ", unit_type)
		return
	sprite.texture = TEXTURE_MAP[owner_id][unit_type]
	sprite.scale = scale
	if unit_type == enums.UnitType.INFANTRY:
		sprite.hframes = 13
		sprite.frame = 0
		if owner_id == 2:
			sprite.scale.x *= -1
	if unit_type == enums.UnitType.TANK:
		sprite.hframes = 13
		sprite.frame = 0
		if owner_id == 1:
			sprite.scale.x *= -1
	if unit_type == enums.UnitType.ARTILLERY:
		sprite.hframes = 13
		sprite.frame = 0
		if owner_id == 1:
			sprite.scale.x *= -1
