@tool

class_name UnitVisuals

extends RefCounted

const ANIMATION_MAP: Dictionary = {
	1: {
		enums.UnitType.INFANTRY: {"anim": "allied_infantry_idle", "offset": Vector2(9, -20)},
		enums.UnitType.TANK: {"anim": "allied_armor_idle", "offset": Vector2(6, -5)},
		enums.UnitType.ARTILLERY: {"anim": "allied_artillery_idle", "offset": Vector2(-1, -11)},
	},
	2: {
		enums.UnitType.INFANTRY: {"anim": "axis_infantry_idle", "offset": Vector2(-9, -20)},
		enums.UnitType.TANK: {"anim": "axis_armor_idle", "offset": Vector2(-6, -5)},
		enums.UnitType.ARTILLERY: {"anim": "axis_artillery_idle", "offset": Vector2(1, -11)},
	},
}

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

static func apply_unit_visuals(sprite: AnimatedSprite2D, owner_id: int, unit_type: int) -> void:
	if not ANIMATION_MAP.has(owner_id):
		push_warning("Invalid owner_id in apply_unit_visuals: ", owner_id)
		return
	if not ANIMATION_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type in apply_unit_visuals: ", unit_type)
		return
	var visual_data: Dictionary = ANIMATION_MAP[owner_id][unit_type]
	sprite.offset = visual_data.get("offset")
	sprite.play(visual_data.get("anim"))
	sprite.flip_h = false
	if unit_type == enums.UnitType.INFANTRY:
		if owner_id == 2:
			sprite.flip_h = true
	if unit_type == enums.UnitType.TANK:
		if owner_id == 1:
			sprite.flip_h = true
	if unit_type == enums.UnitType.ARTILLERY:
		if owner_id == 1:
			sprite.flip_h = true
