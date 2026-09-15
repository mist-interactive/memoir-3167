extends CanvasLayer
@onready var match_state: MatchState = $"../../matchState"
@export var info_text: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	match_state.match_state_changed.connect(on_match_state_changed)
	info_text.clear()
	pass # Replace with function body.

func on_match_state_changed(new_state: MatchState.STATE):
	if new_state == MatchState.STATE.ENDED:
		var winner: int = match_state.get_winner()
		info_text.text = "Player " + str(winner) + " wins!"
		visible = true
	elif new_state == MatchState.STATE.PAUSED:
		info_text.text = "Game paused"
		visible = true
	elif new_state == MatchState.STATE.IN_PROGRESS:
		info_text.clear()
		visible = false
	pass
