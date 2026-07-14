class_name CommandCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var card_target: GameEnums.Sector = GameEnums.Sector.ALL
@export var quantity: int = 1
# any other variables the cards might need
#
# 


# creating a .tres card file
# (Right-Click FileSystem -> Create New -> Resource -> search for "CommandCard"), 
