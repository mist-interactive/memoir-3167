extends Node2D
@export var play: Node2D
@export var profile: Node2D
@export var settings: Node2D

@onready var selectedPage: Node2D:
		set(page):
			if selectedPage != null:
				selectedPage.hide()
			selectedPage = page
			selectedPage.show()

func _draw() -> void:
	selectedPage = play

func _on_play_button_down() -> void:
	selectedPage = play
	pass # Replace with function body.

func _on_profile_button_down() -> void:
	selectedPage = profile
	pass # Replace with function body.

func _on_settings_button_down() -> void:
	selectedPage = settings

	pass # Replace with function body.
