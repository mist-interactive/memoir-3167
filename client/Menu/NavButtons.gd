extends Node2D
@export var playBtn: Button
@export var profileBtn: Button
@export var settingsBtn: Button
@onready var selectedBtn: Button:
	set(btn):
		if btn != null && selectedBtn != null && btn != selectedBtn:
			selectedBtn.add_theme_stylebox_override("normal", defaultBtnStyle)
			selectedBtn.add_theme_color_override("font_color", Color(0.87, 0.87, 0.87, 1.0))
		selectedBtn = btn
		selectedBtn.add_theme_stylebox_override("normal", selectedBtnStyle)
		selectedBtn.add_theme_color_override("font_color", Color(0.012, 0.918, 0.871, 1.0))

var selectedBtnStyle: StyleBoxFlat
var defaultBtnStyle: StyleBoxFlat
var defaultTheme: Theme

func _ready() -> void:
	selectedBtnStyle = StyleBoxFlat.new()
	selectedBtnStyle.border_color = Color(0.012, 0.918, 0.871, 1.0)
	selectedBtnStyle.bg_color = Color(0.09, 0.102, 0.145, 1.0)
	selectedBtnStyle.border_width_bottom = 2
	selectedBtnStyle.skew.x = -0.5
	
	defaultBtnStyle = StyleBoxFlat.new()
	defaultBtnStyle.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	defaultBtnStyle.border_width_bottom = 0
	defaultBtnStyle.skew.x = -0.5
	selectedBtn = playBtn
	profileBtn.add_theme_stylebox_override("normal", defaultBtnStyle)
	settingsBtn.add_theme_stylebox_override("normal", defaultBtnStyle)
	
	playBtn.add_theme_stylebox_override("hover", selectedBtnStyle)
	profileBtn.add_theme_stylebox_override("hover", selectedBtnStyle)
	settingsBtn.add_theme_stylebox_override("hover", selectedBtnStyle)
	
	playBtn.add_theme_color_override("font_hover_color", Color(0.012, 0.918, 0.871, 1.0))
	profileBtn.add_theme_color_override("font_hover_color", Color(0.012, 0.918, 0.871, 1.0))
	settingsBtn.add_theme_color_override("font_hover_color", Color(0.012, 0.918, 0.871, 1.0))





func _on_play_button_down() -> void:
	selectedBtn = playBtn
	pass # Replace with function body.


func _on_profile_button_down() -> void:
	selectedBtn = profileBtn
	pass # Replace with function body.


func _on_settings_button_down() -> void:
	selectedBtn = settingsBtn
	pass # Replace with function body.
