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

func _init(initialState: BattlefieldState) -> void:
	name = "UnitManager"
	battlefield = initialState
	map = battlefield.map

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
