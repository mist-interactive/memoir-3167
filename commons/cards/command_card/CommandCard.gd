class_name CommandCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var title_label: String = ""
@export_multiline var description_label: String = ""
@export var card_target: enums.CardTargetSector = enums.CardTargetSector.ALL
@export var quantity: int = 1
@export_group("Visuals")
@export var card_art: Texture2D
# any other variables the cards might need


# creating a .tres card file
# (Right-Click FileSystem -> Create New -> Resource -> search for "CommandCard"), 
