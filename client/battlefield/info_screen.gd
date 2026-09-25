extends CanvasLayer
@onready var match_state: MatchState = $"../../matchState"
@export var info_pane: Node2D
@export var info_text: RichTextLabel

func _ready() -> void:
	visible = false
	match_state.match_state_changed.connect(on_match_state_changed)
	get_viewport().size_changed.connect(_center_info_pane)
	info_text.clear()
	info_text.set_anchors_preset(Control.PRESET_CENTER)
	info_text.fit_content = true
	info_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	_center_info_pane()

func on_match_state_changed(new_state: MatchState.STATE):
	if new_state == MatchState.STATE.ENDED:
		var winner: int = match_state.get_winner()
		if winner == match_state.mySide:
			info_text.text = "You win!"
		else:
			info_text.text = "You lose!"
		visible = true
	elif new_state == MatchState.STATE.PAUSED:
		info_text.text = "Game paused"
		visible = true
	elif new_state == MatchState.STATE.IN_PROGRESS:
		info_text.clear()
		visible = false

func _center_info_pane() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	info_pane.position = (viewport_size / 2)
