extends HexagonTileMapLayer
@onready var matchState: MatchState = $"../../../matchState"
@onready var unit_manager: UnitManager = $"../../../UnitManager"

var player_hex := {}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	clear()
	highlight_selected_units()

func highlight_selected_units() -> void:
	for unit_id in unit_manager.selected_units_ids:
		var unit: Unit = unit_manager.get_unit_by_id(unit_id)
		if unit == null:
			continue
		var highlight_atlas_coordinate := Vector2i(2, 0)
		if !unit.can_act_in_current_phase(matchState.phase):
			highlight_atlas_coordinate = Vector2i(3, 0)
		highlight_cell(unit.hex_coord, highlight_atlas_coordinate)

func highlight_cell(coord: Vector2i, atlas_coordinate: Vector2i = Vector2i(0, 0)) -> void:
	set_cell(coord, 2, atlas_coordinate)
