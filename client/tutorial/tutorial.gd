extends Control

@export var minimize_button: Button
@export var tutorial_button: Button
@export var panel: Panel
@export var text: Label

@export var page_buttons_container: Container

@export var tutorial_pages: Array[Control]
@export var page_buttons: Array[Button]

const DESIGN_SIZE := Vector2(1920, 1080)

var current_page := 0


func _ready() -> void:
	tutorial_button.visible = false

	minimize_button.pressed.connect(_on_minimize_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)

	for i in range(page_buttons.size()):
		page_buttons[i].pressed.connect(_on_page_button_pressed.bind(i))

	get_viewport().size_changed.connect(update_ui)
	update_ui()

	show_page()


func update_ui() -> void:
	var viewport_size := get_viewport_rect().size

	var scale_factor := minf(
		viewport_size.x / DESIGN_SIZE.x,
		viewport_size.y / DESIGN_SIZE.y
	)

func show_page() -> void:
	for page in tutorial_pages:
		page.visible = false

	if tutorial_pages.size() > 0:
		tutorial_pages[current_page].visible = true


func _on_page_button_pressed(page_index: int) -> void:
	if page_index >= 0 and page_index < tutorial_pages.size():
		current_page = page_index
		show_page()


func _on_minimize_pressed() -> void:
	panel.visible = false

	for page in tutorial_pages:
		page.visible = false

	for button in page_buttons:
		button.visible = false

	minimize_button.visible = false
	tutorial_button.visible = true
	page_buttons_container.visible = false


func _on_tutorial_pressed() -> void:
	panel.visible = true
	minimize_button.visible = true
	tutorial_button.visible = false
	page_buttons_container.visible = true
	

	for button in page_buttons:
		button.visible = true

	show_page()
