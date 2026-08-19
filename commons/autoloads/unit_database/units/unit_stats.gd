class_name UnitStats
extends Resource

@export var type: enums.UnitType

@export_group("Movement")
@export var max_movement: int = 2
@export var max_movement_and_attack: int = 1
@export var can_move_and_attack: bool = true

@export_group("Combat")
@export var health: int = 4
@export var max_attack_range: int = 3
## Represents dice rolled at specific distances. 
## Index 0 = Range 1, Index 1 = Range 2, etc.
@export var attack_dice_by_distance: Array[int] = []
@export var attacks_ignore_terrain: bool = false
@export var can_overrun: bool = false
@export var can_take_ground: bool = false
