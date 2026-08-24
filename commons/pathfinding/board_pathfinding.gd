class_name BoardPathfinding
extends RefCounted

static func get_line_of_sight(from_hex: Vector2i, to_hex: Vector2i, map: HexGrid, occupied_coords: Dictionary) -> bool:
	if from_hex == to_hex:
		return true
	var from_elevation: float = _get_hex_elevation(from_hex, map)
	var to_elevation: float = _get_hex_elevation(to_hex, map)
	var max_sight_elevation: float = maxf(from_elevation, to_elevation)
	
	# Apply a microscopic nudge to force floating-point rounding to both sides of an edge
	var epsilon := Vector3(1e-5, 2e-5, -3e-5)
	var line_a: Array[Vector2i] = _hex_line_epsilon(from_hex, to_hex, epsilon)
	var line_b: Array[Vector2i] = _hex_line_epsilon(from_hex, to_hex, -epsilon)
	
	var path_a_clear: bool = _is_line_clear(line_a, from_hex, to_hex, max_sight_elevation, map, occupied_coords)
	var path_b_clear: bool = _is_line_clear(line_b, from_hex, to_hex, max_sight_elevation, map, occupied_coords)
	return path_a_clear or path_b_clear

static func get_distance_between_hexes(from_hex: Vector2i, to_hex: Vector2i, map: HexGrid) -> int:
	if from_hex == to_hex:
		return 0
	var distance = map.distance(from_hex, to_hex)
	return distance

static func get_reachable_hexes(unit_type: enums.UnitType, start_coord: Vector2i, map: HexGrid, occupied_coords: Dictionary) -> Dictionary:
	var stats: UnitStats = UnitDatabase.get_stats(unit_type)
	if !stats:
		return {}
	var search_cfg := PathFinder.SearchConfig.new()
	search_cfg.max_cost = float(stats.max_movement)
	search_cfg.neighbor_filter = _neighbor_filter.bind(unit_type, map, occupied_coords)
	search_cfg.cost_fn = _cost_fn.bind(unit_type, map, search_cfg.max_cost)
	search_cfg.should_exit = _should_exit
	search_cfg.priority_fn = _priority_fn
	
	var came_from: Dictionary = {}
	search_cfg.on_better_path = _on_better_path.bind(came_from)
	
	var result_costs: Dictionary = PathFinder._search(start_coord, map, search_cfg)
	return {
		"costs": result_costs,
		"came_from": came_from
	}

static func reconstruct_path(start: Vector2i, target: Vector2i, came_from: Dictionary) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current: Vector2i = target
	while current != start:
		path.append(current)
		if not came_from.has(current):
			push_error("Path broken. Hex not found in came_from.")
			return []
		current = came_from[current]
	path.reverse()
	return path

static func get_unit_path(unit: Variant, start: Vector2i, destination: Vector2i, map: HexGrid, occupied_coords: Dictionary) -> Array[Vector2i]:
	var reachable_data: Dictionary = get_reachable_hexes(unit.type, start, map, occupied_coords)
	var path = reconstruct_path(start, destination, reachable_data.get("came_from", {}))
	return path

static func _neighbor_filter(current_hex: Vector2i, neighbor_hex: Vector2i, unit_type: enums.UnitType, map: HexGrid, occupied_coords: Dictionary) -> bool:
	if not map.is_valid(neighbor_hex):
		return false
	if occupied_coords.has(neighbor_hex):
		return false
	var terrain_type: int = map.get_cell(neighbor_hex).feature
	#TODO: Add terrains specific logic here later
	return true

static func _cost_fn(current_hex: Vector2i, neighbor_hex: Vector2i, unit_type: enums.UnitType, map: HexGrid, max_cost: float) -> float:
	var terrain_type: int = map.get_cell(neighbor_hex).feature
	if terrain_type == HexCell.Feature.NONE:
		return 1.0
	var movement_cost: float = map.TERRAIN_COST.get(terrain_type, 1.0)
	if movement_cost < 0.0:
		return max_cost + 1.0
	#TODO: Add more logic here later:
	# If terrain forces unit to stop return max_cost
	return movement_cost

static func _should_exit(current: Vector2i) -> bool:
	return false

static func _priority_fn(current: Vector2i, g: float) -> float:
	return g

static func _on_better_path(neighbor: Vector2i, current: Vector2i, cost: float, came_from_dict: Dictionary) -> void:
	came_from_dict[neighbor] = current
	
static func _get_hex_elevation(coord: Vector2i, map: HexGrid) -> int:
	var cell = map.get_cell(coord)
	if !cell:
		return INT8_MAX
	return cell.elevation

static func _hex_line_epsilon(a: Vector2i, b: Vector2i, epsilon: Vector3) -> Array[Vector2i]:
	var n: int = HexGrid.distance(a, b)
	var result: Array[Vector2i] = []
	if n == 0:
		result.append(a)
		return result
	var ca: Vector3 = HexGrid._cube_to_float(HexGrid.offset_to_cube(a)) + epsilon
	var cb: Vector3 = HexGrid._cube_to_float(HexGrid.offset_to_cube(b)) + epsilon
	for i in range(n + 1):
		var t: float = float(i) / float(n)
		var lerped := Vector3(
			ca.x + (cb.x - ca.x) * t,
			ca.y + (cb.y - ca.y) * t,
			ca.z + (cb.z - ca.z) * t
		)
		result.append(HexGrid._cube_to_offset(HexGrid.cube_round(lerped.x, lerped.z)))
	return result

static func _is_line_clear(line: Array[Vector2i], from_hex: Vector2i, to_hex: Vector2i, max_sight_elevation: float, map: HexGrid, occupied_coords: Dictionary) -> bool:
	for coord in line:
		if coord == from_hex || coord == to_hex:
			continue
		if occupied_coords.has(coord):
			return false
		var cell = map.get_cell(coord)
		if !cell:
			return false
		var current_elevation: float = cell.elevation
		if current_elevation > max_sight_elevation:
			return false
	return true
