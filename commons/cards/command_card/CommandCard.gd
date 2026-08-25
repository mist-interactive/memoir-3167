class_name CommandCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var title_label: String = ""
@export_multiline var description_label: String = ""
@export_multiline var description_label_bottom: String = ""
@export var target_sector: enums.CardTargetSector = enums.CardTargetSector.NONE
@export var deck_quantity: int = 1
@export var target_unit: enums.UnitType = enums.UnitType.ANY
@export var target_unit_limit: int = 1
@export_group("Visuals")
@export var card_art: Texture2D

func get_map_sectors() -> Array[enums.MapSector]:
	var result: Array[enums.MapSector] = []
	if target_sector & enums.MapSector.LEFT:
		result.append(enums.MapSector.LEFT)
	if target_sector & enums.MapSector.CENTER:
		result.append(enums.MapSector.CENTER)
	if target_sector & enums.MapSector.RIGHT:
		result.append(enums.MapSector.RIGHT)
	return result
