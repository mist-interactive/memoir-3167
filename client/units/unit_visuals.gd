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

const FORMATIONS: Dictionary = {
	enums.UnitType.INFANTRY: {
		4: [Vector2(-24, -24), Vector2(24, -24), Vector2(24, 24), Vector2(-24, 24)],
		3: [Vector2(0, -24), Vector2(-24, 12), Vector2(24, 12)],
		2: [Vector2(-24, 0), Vector2(24, 0)],
		1: [Vector2(0, 0)],
	},
	enums.UnitType.TANK: {
		4: [Vector2(-36, -36), Vector2(36, -36), Vector2(36, 36), Vector2(-36, 36)],
		3: [Vector2(4, -50), Vector2(-28, -10), Vector2(25, 9)],
		2: [Vector2(-36, 0), Vector2(36, 0)],
		1: [Vector2(0, 0)],
	},
	enums.UnitType.ARTILLERY: {
		4: [Vector2(-36, -36), Vector2(36, -36), Vector2(36, 36), Vector2(-36, 36)],
		3: [Vector2(4, -50), Vector2(-28, -10), Vector2(25, 9)],
		2: [Vector2(-36, 0), Vector2(36, 0)],
		1: [Vector2(0, 0)],
	}
}

const base_atlas: CompressedTexture2D = preload("res://assets/sprites/units/unit_bases.png")

static var scale: Vector2 = Vector2(1, 1)

static func update_unit_visuals(unit: Unit) -> void:
	apply_unit_visuals(unit.unit_figures, unit.owner_id, unit.type, unit.hit_point)

static func apply_unit_visuals(unit_figures: Array[Variant], owner_id: int, unit_type: int, unit_health: int) -> void:
	if not ANIMATION_MAP.has(owner_id):
		push_warning("Invalid owner_id in apply_unit_visuals: ", owner_id)
		return
	if not ANIMATION_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type in apply_unit_visuals: ", unit_type)
		return
	for i in range(unit_figures.size()):
		apply_figure_visuals(unit_figures[i], owner_id, unit_type, unit_health, i)


static func apply_figure_visuals(unit_figure: Variant, owner_id: int, unit_type: int, unit_health: int, index: int) -> void:
	if not ANIMATION_MAP.has(owner_id):
		push_warning("Invalid owner_id in apply_unit_visuals: ", owner_id)
		return
	if not ANIMATION_MAP[owner_id].has(unit_type):
		push_warning("Invalid unit_type in apply_unit_visuals: ", unit_type)
		return
	if index >= unit_health:
		unit_figure.visible = false
		return
	var visual_data: Dictionary = ANIMATION_MAP[owner_id][unit_type]
	var figure_offset = FORMATIONS.get(unit_type).get(unit_health)
	unit_figure.position = figure_offset[index]
	unit_figure.z_index = index
	unit_figure.anim_sprite.offset = visual_data.get("offset")
	unit_figure.anim_sprite.play(visual_data.get("anim"))
	unit_figure.anim_sprite.flip_h = false
	unit_figure.base_sprite.texture = base_atlas
	unit_figure.base_sprite.hframes = 2
	if owner_id == 2:
		unit_figure.base_sprite.frame = 1
	if unit_type == enums.UnitType.INFANTRY:
		unit_figure.base_sprite.scale = Vector2(1, 1)
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
