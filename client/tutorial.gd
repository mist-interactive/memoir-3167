extends Control

@export var minimize_button: Button
@export var tutorial_button: Button
@export var panel: ColorRect
@export var text: Label

@export var tutorial_pages: Array[Control]
@export var page_buttons: Array[Button]

var current_page := 0

func _ready() -> void:
	tutorial_button.visible = false
	minimize_button.pressed.connect(_on_minimize_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)

	for i in range(page_buttons.size()):
		page_buttons[i].pressed.connect(_on_page_button_pressed.bind(i))

	show_page()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		next_page()

func show_page() -> void:
	for page in tutorial_pages:
		page.visible = false
	if tutorial_pages.size() > 0:
		tutorial_pages[current_page].visible = true

func next_page() -> void:
	if current_page < tutorial_pages.size() - 1:
		current_page += 1
		show_page()

func _on_page_button_pressed(page_index: int) -> void:
	if page_index < tutorial_pages.size():
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

func _on_tutorial_pressed() -> void:
	panel.visible = true
	minimize_button.visible = true
	tutorial_button.visible = false
	for button in page_buttons:
		button.visible = true
	show_page()
