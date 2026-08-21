class_name BoardPathfinding
extends RefCounted

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
