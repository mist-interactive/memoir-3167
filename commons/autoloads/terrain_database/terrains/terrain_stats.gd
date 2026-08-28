@tool

class_name TerrainStats
extends Resource

@export_group("Type and LOS")
@export var terrain_type: HexCell.Feature

@export_range(0, 2) var elevation: int = 0

@export var blocks_line_of_sight: bool = false

@export_group("Unit max movement on terrain (0 to 5)")
@export_range(0, 5) var infantry_max_movement_on_terrain: int = 3
@export_range(0, 5) var armor_max_movement_on_terrain: int = 3
@export_range(0, 5) var artillery_max_movement_on_terrain: int = 1
func get_unit_max_movement(unit_type: enums.UnitType) -> int:
	match(unit_type):
		enums.UnitType.INFANTRY:
			return infantry_max_movement_on_terrain
		enums.UnitType.TANK:
			return armor_max_movement_on_terrain
		enums.UnitType.ARTILLERY:
			return artillery_max_movement_on_terrain
	return 0

@export_group("Unit can move in and fight")
@export_flags("Infantry:1", "Armor:2", "Artillery:4") var can_move_in_and_fight: int = 0
func unit_can_move_in_and_fight(unit_type: enums.UnitType) -> bool:
	return (can_move_in_and_fight & unit_type != 0)

@export_group("Ignore first flag")
@export_flags("Infantry:1", "Armor:2", "Artillery:4") var can_ignore_first_flag: int = 0
func unit_can_ignore_first_flag(unit_type: enums.UnitType) -> bool:
	return (can_ignore_first_flag & unit_type != 0)

@export_group("Defense Modifiers (-3 to 0 dice)")
@export_range(-3, 0) var infantry_defense_modifier: int = 0
@export_range(-3, 0) var armor_defense_modifier: int = 0
@export_range(-3, 0) var artillery_defense_modifier: int = 0
func get_unit_defense_modifier(unit_type: enums.UnitType) -> int:
	match(unit_type):
		enums.UnitType.INFANTRY:
			return infantry_defense_modifier
		enums.UnitType.TANK:
			return armor_defense_modifier
		enums.UnitType.ARTILLERY:
			return artillery_defense_modifier
	return 0

@export_group("Attack Modifiers (-3 to 0 dice)")
@export_range(-3, 0) var infantry_attack_modifier: int = 0
@export_range(-3, 0) var armor_attack_modifier: int = 0
@export_range(-3, 0) var artillery_attack_modifier: int = 0
func get_unit_attack_modifier(unit_type: enums.UnitType) -> int:
	match(unit_type):
		enums.UnitType.INFANTRY:
			return infantry_attack_modifier
		enums.UnitType.TANK:
			return armor_attack_modifier
		enums.UnitType.ARTILLERY:
			return artillery_attack_modifier
	return 0
