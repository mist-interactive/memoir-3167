extends HexagonTileMapLayer
@onready var matchState: MatchState = $"../../../matchState"
@onready var unit_manager: UnitManager = $"../../../UnitManager"

var player_hex := {}

func _ready() -> void:
	pass

#func _physics_process(delta: float) -> void:
	#clear()
	#match matchState.phase:
		#enums.TurnPhase.SELECT:
			#highlight_selected_units()
		#enums.TurnPhase.MOVE:
			#highlight_movable_units()
		#enums.TurnPhase.ATTACK:
			#highlight_attackable_units()
		#_:
			#pass

#func highlight_selected_units() -> void:
	#for unit_id in unit_manager.selected_units_ids:
		#var unit = unit_manager.get_unit_by_id(unit_id)
		#if unit == null:
			#continue
		#highlight_cell(unit.hex_coord)
#
#func highlight_movable_units() -> void:
	#for unit_id in unit_manager.selected_units_ids:
		#var unit = unit_manager.get_unit_by_id(unit_id)
		#if unit == null:
			#continue
		#if unit_id in unit_manager.moved_units_ids:
			#continue
		#highlight_cell(unit.hex_coord)
#
#func highlight_attackable_units() -> void:
	#for unit_id in unit_manager.selected_units_ids:
		#var unit = unit_manager.get_unit_by_id(unit_id)
		#if unit == null:
			#continue
		#if unit_id in unit_manager.attacked_units_ids:
			#continue
		#highlight_cell(unit.hex_coord)

func highlight_cell(coord: Vector2i) -> void:
	set_cell(coord, 0, Vector2i(0, 0))
