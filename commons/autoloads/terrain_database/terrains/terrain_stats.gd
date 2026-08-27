class_name TerrainStats
extends Resource

@export_group("Movement and LOS")
@export var terrain_type: HexCell.Feature
@export var elevation: int = 0
@export var blocks_line_of_sight: bool = false
@export var unit_can_move_in: Array[int] = []
@export var unit_max_movement_on_terrain: Array[int] = []

@export_group("Combat")
@export var unit_moving_in_can_fight: Array [int] = []
@export var unit_can_ignore_first_flag: Array[int] = []
@export var unit_defence_modifier: Array[int] = []
@export var unit_attack_modifier: Array[int] = []
