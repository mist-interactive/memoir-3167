class_name TerrainCardUI
extends Control

@export var title_label: Label
@export var description_label: Label

@onready var background_texture: TextureRect = $Control/background_texture
@onready var terrain_infantry_art: TextureRect = $Control/terrain_infantry_art
@onready var terrain_tank_art: TextureRect = $Control/terrain_tank_art

@export var effect_label: Label
@export var infantry_negate_count: Label
@export var tank_negate_count: Label

var _card_id: String

func _ready() -> void:
	$Control.visible = false

func setup_visuals(id: String) -> void:
	$Control.visible = true
	_card_id = id
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	var card_data: TerrainCard = CardDatabase.get_card(id)

	if not card_data:
		push_error("Card UI: Database missing definition for " + id)
		return

	title_label.text = card_data.title_label
	description_label.text = card_data.description_label
	effect_label.text = card_data.effect_label
	infantry_negate_count.text = card_data.infantry_negate_count
	tank_negate_count.text = card_data.tank_negate_count

	background_texture.texture = card_data.card_art
	terrain_infantry_art.texture = card_data.infantry_art
	terrain_tank_art.texture = card_data.tank_art

func hide_elements() -> void:
	$Control.visible = false
