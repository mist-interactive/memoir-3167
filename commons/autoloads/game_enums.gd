extends Node
class_name enums

enum UnitType
{
	INFANTRY,
	TANK,
	ARTILLERY,
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
	RIGHT  = 2 << 1, # 4 (or 1 << 2)

	# Composite Card Target Sectors (Combined Bits)
	LEFT_CENTER  = LEFT | CENTER,   # 3 (001 | 010 = 011)
	RIGHT_CENTER = CENTER | RIGHT,  # 6 (010 | 100 = 110)
	ANY          = LEFT | CENTER | RIGHT, # 7 (111)
	ALL          = ANY                    # 7 (111)
}
