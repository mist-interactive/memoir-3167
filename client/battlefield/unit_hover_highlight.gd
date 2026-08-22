extends HexagonTileMapLayer
@onready var matchState: MatchState = $"../../../matchState"
@onready var unit_manager: UnitManager = $"../../../UnitManager"

var player_hex := {}

func _ready() -> void:
	pass

func highlight_cell(coord: Vector2i) -> void:
	set_cell(coord, 0, Vector2i(0, 0))
