extends Node
class_name enums

enum Side
{
	GREEN = 1,
	RED = 2,
	NONE = 3
}

enum UnitType
{
	INFANTRY,
	TANK,
	ARTILLERY,
	ANY,
}

enum RolledDice
{
	INFANTRY_1,
	INFANTRY_2,
	ALL,
	ARMOR,
	RETREAT,
	MISS,
}

enum MapSector
{
	NONE = 0,
	LEFT = 1 << 0,
	CENTER = 1 << 1,
	RIGHT = 1 << 2,
}

enum CardTargetSector {
	NONE = 0,
	
	# Base Physical Sectors (Single Bits)
	LEFT   = 1 << 0, # 1 
	CENTER = 1 << 1, # 2
	RIGHT  = 1 << 2, # 4 (or 1 << 2)

	# Composite Card Target Sectors (Combined Bits)
	LEFT_CENTER  = LEFT | CENTER,   # 3 (001 | 010 = 011)
	RIGHT_CENTER = CENTER | RIGHT,  # 6 (010 | 100 = 110)
	LEFT_RIGHT = LEFT | RIGHT,      # 5 (101)
	ALL          = LEFT | CENTER | RIGHT # 7 (111)
}

enum TurnPhase
{
	SPAWN_UNITS,
	DRAW_HAND,
	PLAY_CARD,
	SELECT,
	MOVE,
	ATTACK,
	DRAW_CARD
}
