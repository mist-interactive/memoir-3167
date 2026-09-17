class_name CombatResolver
extends RefCounted

static func get_attack_dice_count(attacker: Variant, attacker_hex: HexCell, defender: Variant, defender_hex: HexCell, distance: int) -> int:
	var attacker_stats: UnitStats = UnitDatabase.get_stats(attacker.type)
	if !attacker_stats:
		push_warning("No attacker stats found for unit type ", attacker.type)
		return 0
	if distance > attacker_stats.max_attack_range || distance < 0:
		return 0
		
	var defender_stats: UnitStats = UnitDatabase.get_stats(defender.type)
	if !defender_stats:
		push_warning("No defender stats found for unit type ", attacker.type)
		return 0
		
	var attacker_terrain_stats: TerrainStats = TerrainDatabase.get_stats(attacker_hex.ground)
	if !attacker_terrain_stats:
		push_warning("No attacker terrain stats found for terrain type ", attacker_hex.ground)
		return 0
		
	var defender_terrain_stats: TerrainStats = TerrainDatabase.get_stats(defender_hex.ground)
	if !defender_terrain_stats:
		push_warning("No defender terrain stats found for terrain type ", defender_hex.ground)
		return 0
	var dice_count = attacker_stats.get_attack_dice_by_distance(distance)
	dice_count += attacker_terrain_stats.get_unit_attack_modifier(attacker.type)
	dice_count += defender_terrain_stats.get_unit_defense_modifier(defender.type)
	return dice_count
