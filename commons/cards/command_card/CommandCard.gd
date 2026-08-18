class_name CommandCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var title_label: String = ""
@export_multiline var description_label: String = ""
@export var target_sector: enums.CardTargetSector = enums.CardTargetSector.ALL
@export var deck_quantity: int = 1
@export var target_unit: enums.UnitType = enums.UnitType.INFANTRY
@export var target_unit_limit: int = 1
@export_group("Visuals")
@export var card_art: Texture2D

# creating a .tres card file
# (Right-Click FileSystem -> Create New -> Resource -> search for "CommandCard"), 
