@tool

class_name UnitSpawnMarker
extends Sprite2D

@export var unit_type: String = "infantry":
	set(value):
		unit_type = value
		_update_visual()
		
@export var owner_id: int = 1:
	set(value):
		owner_id = value
		_update_visual()
"""
func serialize(coord: Vector2i) -> Dictonary:
	return {
		"coord_x": coord.x,
		"coord_y": coord.y,
		"type": unit_type,
		"owner_id": owner_id
		}
"""

func _update_visual() -> void:
	if Engine.is_editor_hint():
		pass
	pass
