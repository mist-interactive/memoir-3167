extends Control

@export var leftBox: TextureRect
@export var leftBar: Control

@onready var bar_1: TextureRect = leftBar.get_child(0)
@onready var bar_2: TextureRect = leftBar.get_child(1)
@onready var bar_3: TextureRect = leftBar.get_child(2)

@export var terrain_card_ui: TerrainCardUI

var box_default_position: Vector2
var box_default_scale: Vector2

var bar_1_default_position: Vector2
var bar_2_default_position: Vector2
var bar_3_default_position: Vector2

const BOX_NEW_POSITION = 128 * 2
const BOX_NEW_SCALE = Vector2(10, 10)


func _ready() -> void:
	box_default_position = leftBox.position
	box_default_scale = leftBox.scale

	bar_1_default_position = bar_1.position
	bar_2_default_position = bar_2.position
	bar_3_default_position = bar_3.position


func resize() -> void:
	var offset_x := BOX_NEW_POSITION - leftBox.position.x

	leftBox.position.x += offset_x

	bar_1.position.x += offset_x
	bar_2.position.x += offset_x
	bar_3.position.x += offset_x

	leftBox.scale = BOX_NEW_SCALE


func restore() -> void:
	leftBox.position = box_default_position
	leftBox.scale = box_default_scale

	bar_1.position = bar_1_default_position
	bar_2.position = bar_2_default_position
	bar_3.position = bar_3_default_position
	
	terrain_card_ui.hide_elements()
