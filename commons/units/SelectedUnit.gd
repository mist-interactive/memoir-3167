extends RefCounted
class_name SelectedUnit
var unit_id: int
var sector: enums.MapSector

func _init(unit_id: int, sector: enums.MapSector) -> void:
	self.unit_id = unit_id
	self.sector = sector
