@tool

class_name UnitSpawnMarker
extends Sprite2D

var _hex_map: TileMapLayer = null

const TEXTURE_MAP: Dictionary = {
	[1, "infantry"]: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
	[2, "infantry"]: preload("res://assets/sprites/units/infantry_sprite_sheet.png"),	
	[1, "tank"]: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
	[2, "tank"]: preload("res://assets/sprites/units/tank_sprite_sheet.png"),	
	[1, "artillery"]: preload("res://assets/sprites/units/artillery_sprite_sheet.png"),	
	[2, "artillery"]: preload("res://assets/sprites/units/artillery_sprite_sheet.png"),	
}

var sprite_sheet
var _is_snapping: bool = false

func _ready() -> void:
	_update_visual()
	_update_node_name()
	if Engine.is_editor_hint():
		set_notify_local_transform(true)

@export_enum("infantry", "tank", "artillery") var unit_type: String = "infantry":
	set(value):
		unit_type = value
		_update_node_name()
		_update_visual()

@export_enum("Player 1:1", "Player 2:2") var owner_id: int = 1:
	set(value):
		owner_id = value
		_update_node_name()
		_update_visual()

func serialize(coord: Vector2i) -> Dictionary:
	return {
		"coord_x": coord.x,
		"coord_y": coord.y,
		"type": unit_type,
		"owner_id": owner_id
		}

func _update_visual() -> void:
	if !Engine.is_editor_hint():
		return
	var key = [owner_id, unit_type]
	if TEXTURE_MAP.has(key):
		sprite_sheet = TEXTURE_MAP.get(key)
	else:
		push_warning("No sprite sheet found with the key: ", key)
		return
	scale = Vector2(6, 6)
	texture = sprite_sheet
	if unit_type == "infantry":
		hframes = 4
		vframes = 5
		if owner_id == 1:
			frame = 0
		if owner_id == 2:
			frame = 16
	if unit_type == "tank":
		hframes = 5
		vframes = 5
		if owner_id == 1:
			frame = 0
		if owner_id == 2:
			frame = 20
	if unit_type == "artillery":
		hframes = 6
		vframes = 5
		if owner_id == 1:
			frame = 0
		if owner_id == 2:
			frame = 24

func _get_hex_map() -> TileMapLayer:
	if _hex_map != null:
		return _hex_map
	if not is_inside_tree():
		return null
	var editor_root: Node = get_tree().edited_scene_root
	if editor_root != null:
		var found_maps: Array[Node] = editor_root.find_children("*", "TileMapLayer", true, false)
		if found_maps.size() > 0:
			_hex_map = found_maps[0] as TileMapLayer
	return _hex_map

func _snap_to_hex() -> void:
	_is_snapping = true
	var map: TileMapLayer = _get_hex_map()
	var grid_pos: Vector2i = map.local_to_map(position)
	var snapped_position: Vector2 = map.map_to_local(grid_pos)
	position = snapped_position
	_is_snapping = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		if Engine.is_editor_hint() and not _is_snapping:
			if _get_hex_map() != null:
				_snap_to_hex()

func _update_node_name() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	call_deferred("_reindex_group")

func _reindex_group() -> void:
	if not is_inside_tree() or get_parent() == null:
		return
	var parent: Node = get_parent()
	var markers: Array[Node] = []
	
	# Filter units based on owner and type
	for child in parent.get_children():
		if child is UnitSpawnMarker:
			markers.append(child)
			
	markers.sort_custom(func(a: Node, b: Node):
		if a.owner_id != b.owner_id:
			return a.owner_id < b.owner_id
		if a.unit_type != b.unit_type:
			return a.unit_type < b.unit_type
		return a.get_index() < b.get_index())

	for i in range(markers.size()):
		var target = markers[i]
		target.name = "Temp_%d" % target.get_instance_id()

	var current_owner: int = -1
	var current_type: String = ""
	var count: int = 0
	
	for i in range(markers.size()):
		var target = markers[i]
		if target.owner_id != current_owner or target.unit_type != current_type:
			current_owner = target.owner_id
			current_type = target.unit_type
			count = 0
		else:
			count += 1
		var expected_name = "Player%s_%s_%d" % [current_owner, current_type, count + 1]
		if target.name != expected_name:
			target.name = expected_name
		parent.move_child(target, i)
