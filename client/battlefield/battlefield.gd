extends Node2D

@export var unit_container: Node

var unit_manager: UnitManager

func _ready() -> void:
	unit_manager = UnitManager.new()
	unit_manager.active_container = unit_container
	add_child(unit_manager)
