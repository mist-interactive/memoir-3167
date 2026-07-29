class_name UnitManager
extends Node

# The Unit Grid:
# Key = Vector2i (hex coord), Value = Unit
var unit_grid: Dictionary = {}
var units_by_id: Dictionary = {}
var active_container: Node
var _unit_id_counter: int = 0

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

func move_unit(unit: Variant, old_coord: Vector2i, new_coord: Vector2i) -> void:
		remove_unit(old_coord)
		add_unit(unit, new_coord)

func get_unit_at(coord: Vector2i) -> Variant:
	return unit_grid.get(coord)
	
func get_unit_by_id(id: int) -> Variant:
	return units_by_id.get(id)
	
func generate_server_unit_id() -> int:
	if not multiplayer.is_server():
		push_error("Client tried to generate a unit ID.")
		return -1
	_unit_id_counter += 1
	return _unit_id_counter
