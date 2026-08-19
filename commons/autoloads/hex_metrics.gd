extends Node

# The circumscribed radius (half the width of a flat-top tile).
# Set this to match the X dimension of your TileSet divided by 2.
const HEX_SIZE: float = 512 / 2
const SQRT3: float = 1.7320508075688772

var tile_width: float
var tile_height: float
var half_width: float
var half_height: float

func _ready() -> void:
	_calculate_dimensions()
	
func _calculate_dimensions() -> void:
	tile_width = HEX_SIZE * SQRT3
	tile_height = HEX_SIZE * 2.0
	half_width = tile_width / 2.0
	half_height = HEX_SIZE
