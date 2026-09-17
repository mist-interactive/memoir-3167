class_name UnitManager
extends Node

# The Unit Grid:
# Key = Vector2i (hex coord), Value = Unit
var unit_grid: Dictionary[Vector2i, int] = {} # hex_coords --> id
var units_by_id: Dictionary[int, Variant] = {} # id --> unit
var map: HexGrid
var battlefield: BattlefieldState
var selected_unit_id: int = -1
var selected_by_peer: enums.Side = enums.Side.NONE
var selected_units_ids: Array[int]
var moved_units_ids: Array[int]
var attacked_units_ids: Array[int]
var base_dir: Dictionary[enums.Side, Vector2i]

func _init(initialState: BattlefieldState) -> void:
	name = "UnitManager"
	battlefield = initialState
	map = battlefield.map
	base_dir[enums.Side.GREEN] = battlefield.base_dir_1
	base_dir[enums.Side.RED] = battlefield.base_dir_2

func add_unit(unit: Variant, coord: Vector2i) -> void:
	if !map.cells.has(coord) || unit_grid.has(coord):
		return
	unit.hex_coord = coord
	unit_grid[coord] = unit.uuid
	units_by_id[unit.uuid] = unit
	#if multiplayer.is_server():
		#print("Unit registered at ", coord, " | Total units: ", unit_grid.size())
		#
func remove_unit(coord: Vector2i) -> void:
	if unit_grid.has(coord):
		var uuid: int = unit_grid[coord]
		units_by_id.erase(uuid)
		unit_grid.erase(coord)

func move_unit(unit: Variant, old_coord: Vector2i, new_coord: Vector2i) -> bool:
	if !unit_grid.has(old_coord) || !map.cells.has(new_coord) || unit_grid.has(new_coord) :
		return false
	var uuid: int = unit_grid[old_coord]
	if unit.uuid != uuid:
		return false
	unit_grid[new_coord] = unit.uuid
	units_by_id[uuid].hex_coord = new_coord
	unit.hex_coord = new_coord
	unit_grid.erase(old_coord)
	return true

func get_unit_at(coord: Vector2i) -> Variant:
	if !unit_grid.has(coord):
		return null
	var uuid: int = unit_grid[coord]
	return units_by_id[uuid]
	
func get_unit_by_id(id: int) -> Variant:
	return units_by_id.get(id)

func get_occupied_coords() -> Dictionary:
	var occupied_coords: Dictionary = {}
	for coord in unit_grid.keys():
		occupied_coords[coord] = true
	return occupied_coords
			

func get_enemies_within_range_and_los(unit: Variant) -> Dictionary:
	# unit uuid, coord
	var valid_targets: Dictionary[int, Vector2i] = {}
	var unit_stats: UnitStats = UnitDatabase.get_stats(unit.type)
	var unit_max_range: int = unit_stats.max_attack_range
	var occupied_coords: Dictionary = get_occupied_coords()
	for coord in occupied_coords:
		if coord == unit.hex_coord:
			continue
		var other_unit = get_unit_at(coord)
		if !other_unit:
			push_error("Unit occupied coords and unit_grid don't match!")
			continue
		if other_unit.owner_id == unit.owner_id:
			continue
		if map.distance(unit.hex_coord, other_unit.hex_coord) > unit_max_range:
			continue
		if unit_stats.attacks_ignore_los:
			valid_targets[other_unit.uuid] = coord
			continue
		elif BoardPathfinding.get_line_of_sight(unit.hex_coord, other_unit.hex_coord, map, occupied_coords):
			valid_targets[other_unit.uuid] = coord
			continue
	return valid_targets

func get_retreat_coords(side: enums.Side, coord: Vector2i, unit: Variant, retreat: int) -> BinaryTree:
	if retreat < 0:
		return null
	var tree: BinaryTree = BinaryTree.new(coord);
	var left_coord: Vector2i = Vector2i(coord.x if coord.y % 2 != 0 else coord.x - 1 , coord.y + base_dir[side].y)
	var right_coord: Vector2i = Vector2i(coord.x if coord.y % 2 == 0 else coord.x + 1 , coord.y + base_dir[side].y)
	var cell: HexCell = battlefield.map.get_cell(coord);
	if is_traversable(unit, left_coord):
		tree.left = get_retreat_coords(side, left_coord, unit, retreat - 1)
	if is_traversable(unit, right_coord):
		tree.right = get_retreat_coords(side, right_coord, unit, retreat - 1)
	return tree

func is_traversable(unit: Variant, coord: Vector2i) -> bool:
	var cell: HexCell = battlefield.map.get_cell(coord)
	if !cell || unit_grid.has(coord):
		return false
	var terrain_stats: TerrainStats = TerrainDatabase.get_stats(cell.ground)
	if (!terrain_stats):
		return false
	return terrain_stats.get_unit_max_movement(unit.type) > 0

func has_attackable_unit() -> bool:
	for id: int in selected_units_ids:
		if units_by_id[id].can_attack():
			return true
	return false

func has_movable_unit() -> bool:
	for id: int in selected_units_ids:
		if units_by_id[id].can_move():
			return true
	return false

func has_retreatable_unit() -> bool:
	for unit: UnitData in units_by_id.values():
		if unit.must_retreat():
			return true
	return false

func get_retreating_unit() -> Variant:
	for unit: UnitData in units_by_id.values():
		if unit.must_retreat():
			return unit
	return null
