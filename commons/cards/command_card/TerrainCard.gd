class_name TerrainCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var title_label: String = ""
@export var effect_label: String = ""
@export_multiline var description_label: String = ""
@export var infantry_negate_count: String = ""
@export var tank_negate_count: String = ""
@export_group("Visuals")
@export var card_art: Texture2D
@export var infantry_art: Texture2D
@export var tank_art: Texture2D
