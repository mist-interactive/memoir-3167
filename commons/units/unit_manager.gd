class_name UnitManager
extends Node

# The Unit Grid:
# Key = Vector2i (hex coord), Value = Unit
var unit_grid: Dictionary = {}
var units_by_id: Dictionary = {}
var active_container: Node

func add_unit(unit: Variant, coord: Vector2i) -> void:
	if unit_grid.has(coord):
		return
	unit_grid[coord] = unit
	units_by_id[unit.uuid] = unit
	if multiplayer.is_server():
		print("Unit registered at ", coord, " | Total units: ", unit_grid.size())
	
func remove_unit(coord: Vector2i) -> void:
	if unit_grid.has(coord):
		var unit_to_remove = unit_grid[coord]
		units_by_id.erase(unit_to_remove.uuid)
		unit_grid.erase(coord)

# Add this? Change declaration to use Variant?		
'''
func remove_unit(id: String) -> void:
	if units_by_id.has(id):
		var unit_to_remove = units_by_id[id]
		units_by_id.erase(id)
		unit_grid.erase(unit_to_remove.hex_coord)
'''

func move_unit(unit: Variant, old_coord: Vector2i, new_coord: Vector2i) -> void:
		remove_unit(old_coord)
		add_unit(unit, new_coord)

func get_unit_at(coord: Vector2i) -> Variant:
	return unit_grid.get(coord)
	
func get_unit_by_id(id: String) -> Variant:
	return units_by_id.get(id)
