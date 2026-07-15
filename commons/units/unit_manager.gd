extends Node

# The Unit Grid:
# Key = Vector2i (hex coord), Value = Unit
var unit_grid: Dictionary = {}

func add_unit(unit: Node2D, coord: Vector2i) -> void:
	unit_grid[coord] = unit
	print("Unit registered at ", coord, " | Total units: ", unit_grid.size())
	
func remove_unit(coord: Vector2i) -> void:
	if unit_grid.has(coord):
		unit_grid.erase(coord)

func move_unit(unit: Node2D, old_coord: Vector2i, new_coord: Vector2i) -> void:
		remove_unit(old_coord)
		add_unit(unit, new_coord)

func get_unit_at(coord: Vector2i) -> Node2D:
	return unit_grid.get(coord)
