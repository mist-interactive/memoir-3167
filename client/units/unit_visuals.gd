@tool

class_name UnitVisuals

extends RefCounted

const ANIMATION_MAP: Dictionary = {
	1: {
		enums.UnitType.INFANTRY: {"anim": "allied_infantry_idle", "offset": Vector2(9, -15)},
		enums.UnitType.TANK: {"anim": "allied_armor_idle", "offset": Vector2(4, 5)},
		enums.UnitType.ARTILLERY: {"anim": "allied_artillery_idle", "offset": Vector2(4, -2)},
	},
	2: {
		enums.UnitType.INFANTRY: {"anim": "axis_infantry_idle", "offset": Vector2(-9, -15)},
		enums.UnitType.TANK: {"anim": "axis_armor_idle", "offset": Vector2(-4, 5)},
		enums.UnitType.ARTILLERY: {"anim": "axis_artillery_idle", "offset": Vector2(-4, -2)},
	},
}

const base_atlas: CompressedTexture2D = preload("res://assets/sprites/units/unit_bases.png")

static var scale: Vector2 = Vector2(1, 1)

static func apply_unit_visuals(unit_figure: Variant, owner_id: int, unit_type: int) -> void:
	if not ANIMATION_MAP.has(owner_id):
		push_warning("Invalid owner_id in apply_unit_visuals: ", owner_id)
		return
	if not ANIMATION_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type in apply_unit_visuals: ", unit_type)
		return
	var visual_data: Dictionary = ANIMATION_MAP[owner_id][unit_type]
	unit_figure.anim_sprite.offset = visual_data.get("offset")
	unit_figure.anim_sprite.play(visual_data.get("anim"))
	unit_figure.anim_sprite.flip_h = false
	unit_figure.base_sprite.texture = base_atlas
	unit_figure.base_sprite.hframes = 2
	if owner_id == 2:
		unit_figure.base_sprite.frame = 1
	if unit_type == enums.UnitType.INFANTRY:
		if owner_id == 2:
			unit_figure.anim_sprite.flip_h = true
	if unit_type == enums.UnitType.TANK:
		unit_figure.base_sprite.scale = Vector2(1.5, 1.5)
		if owner_id == 1:
			unit_figure.anim_sprite.flip_h = true
	if unit_type == enums.UnitType.ARTILLERY:
		unit_figure.base_sprite.scale = Vector2(1.5, 1.5)
		if owner_id == 1:
			unit_figure.anim_sprite.flip_h = true
