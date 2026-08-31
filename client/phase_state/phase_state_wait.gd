class_name PhaseStateWait
extends PhaseState

## Called when the server transitions the client INTO this phase.
func enter() -> void:
	pass

## Called when the server transitions the client OUT of this phase.
func exit() -> void:
	pass

## Triggered by PlayerController on left click.
func handle_left_click(hex: Vector2i) -> void:
	pass
	
## Triggered by PlayerController on right click.
func handle_right_click(hex: Vector2i) -> void:
	pass

## Triggered by PlayerController when the mouse moves to a new hex.
func handle_mouse_motion(hex: Vector2i) -> void:
	pass
