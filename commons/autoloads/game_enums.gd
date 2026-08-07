extends RefCounted

enum UnitType
{
	INFANTRY,
	TANK,
	ARTILLERY,
}

enum Sector
{
	NONE = 0,
	LEFT = 1 << 0,
	CENTER = 1 << 1,
	RIGHT = 1 << 2,
}
