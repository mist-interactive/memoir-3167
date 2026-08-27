@tool

class_name TerrainStats
extends Resource

@export_group("Movement and LOS")
@export var terrain_type: HexCell.Feature

@export_range(0, 3) var elevation: int = 0

@export var blocks_line_of_sight: bool = false

@export_flags("Infantry:1", "Armor:2", "Artillery:4") var can_move_in: int = int(enums.UnitType.ANY)
func unit_can_move_in(unit_type: enums.UnitType) -> bool:
	return (can_move_in & unit_type != 0)
	
@export var unit_max_movement_on_terrain: Array[int] = []

@export_group("Combat")

@export_flags("Infantry:1", "Armor:2", "Artillery:4") var can_move_in_and_fight: int = 0

@export_flags("Infantry:1", "Armor:2", "Artillery:4") var can_ignore_first_flag: int = 0

@export_group("Defense Modifiers (-5 - 0 dice)")
@export_range(-5, 0) var infantry_defense_modifier: int = 0
@export_range(-5, 0) var armor_defense_modifier: int = 0
@export_range(-5, 0) var artillery_defense_modifier: int = 0
func get_unit_defense_modifier(unit_type: enums.UnitType) -> int:
	match(unit_type):
		enums.UnitType.INFANTRY:
			return infantry_defense_modifier
		enums.UnitType.TANK:
			return armor_defense_modifier
		enums.UnitType.ARTILLERY:
			return artillery_defense_modifier
	return 0

@export_group("Attack Modifiers (-5 - 5 dice)")
@export_range(-5, 5) var infantry_attack_modifier: int = 0
@export_range(-5, 5) var armor_attack_modifier: int = 0
@export_range(-5, 5) var artillery_attack_modifier: int = 0
func get_unit_attack_modifier(unit_type: enums.UnitType) -> int:
	match(unit_type):
		enums.UnitType.INFANTRY:
			return infantry_attack_modifier
		enums.UnitType.TANK:
			return armor_attack_modifier
		enums.UnitType.ARTILLERY:
			return artillery_attack_modifier
	return 0

func unit_can_move_in_and_fight(unit_type: enums.UnitType) -> bool:
	return (can_move_in_and_fight & unit_type != 0)

func unit_can_ignore_first_flag(unit_type: enums.UnitType) -> bool:
	return (can_ignore_first_flag & unit_type != 0)
