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
	NONE = 0,
	INFANTRY = 1 << 0,
	TANK = 1 << 1,
	ARTILLERY = 1 << 2,
	ANY = INFANTRY | TANK | ARTILLERY,
}

enum UnitActions
{
	NONE = 0,
	IS_SELECTED = 1 << 0,
	CAN_MOVE = 1 << 1,
	CAN_ATTACK = 1 << 2,
	MUST_RETREAT = 1 << 3
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
	NONE,
	SPAWN_UNITS,
	DRAW_HAND,
	PLAY_CARD,
	SELECT,
	MOVE,
	ATTACK,
	RESOLVE_RETREAT,
	DRAW_CARD
}

enum ConnectionStatus
{
	NONE = 0,
	Disconnected = 1 << 0,
	Connected = 1 << 1,
	Authenticated = 1 << 2,
	Ready = 1 << 3,
	Playing = 1 << 4,
}
