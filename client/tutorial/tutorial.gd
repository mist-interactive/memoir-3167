extends Control

@export var minimize_button: Button
@export var tutorial_button: Button
@export var menu_button: Button

@export var panel: Panel
@export var menu_panel: Panel
@export var top_bar: Panel

@export var page_buttons_container: Container

@export var tutorial_pages: Array[Control]
@export var page_buttons: Array[Button]

const DESIGN_SIZE := Vector2(1920, 1080)

enum UIState {
	TUTORIAL,
	MINIMIZED,
}

const PAGE_SIZE := Vector2(448.0, 224.0)
const PAGE_POSITION := Vector2(16.0, 32.0)
const PAGE_CUSTOM_MIN := Vector2(448.0, 224.0)
const PAGE_CUSTOM_MAX := Vector2(448.0, 224.0)

var current_state := UIState.TUTORIAL
var current_page := 0
var menu_open := false

var dragging := false
var drag_offset := Vector2.ZERO


func _ready() -> void:
	minimize_button.pressed.connect(_on_minimize_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	for i in range(page_buttons.size()):
		page_buttons[i].pressed.connect(_on_page_button_pressed.bind(i))

	for page in tutorial_pages:
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var rich_text_label: RichTextLabel = page.get_node("Text")
		rich_text_label.size = PAGE_SIZE
		rich_text_label.position = PAGE_POSITION
		rich_text_label.custom_minimum_size = PAGE_CUSTOM_MIN
		rich_text_label.custom_maximum_size = PAGE_CUSTOM_MAX

	top_bar.gui_input.connect(_on_top_bar_input)

	set_ui_state(UIState.TUTORIAL)


func set_ui_state(new_state: UIState) -> void:
	current_state = new_state

	match current_state:
		UIState.TUTORIAL:
			_apply_tutorial_state()

		UIState.MINIMIZED:
			_apply_minimized_state()


func _apply_tutorial_state() -> void:
	panel.visible = true
	top_bar.visible = true

	minimize_button.visible = true
	tutorial_button.visible = false

	menu_button.visible = true
	menu_button.disabled = false

	for button in page_buttons:
		button.visible = true

	apply_menu_state()


func _apply_minimized_state() -> void:
	panel.visible = false
	top_bar.visible = false

	minimize_button.visible = false
	tutorial_button.visible = true

	menu_button.visible = false
	menu_button.disabled = true

	page_buttons_container.visible = false
	menu_panel.visible = false

	menu_open = false

	for page in tutorial_pages:
		page.visible = false
		page.process_mode = Node.PROCESS_MODE_DISABLED

	for button in page_buttons:
		button.visible = false


func apply_menu_state() -> void:
	if current_state != UIState.TUTORIAL:
		menu_panel.visible = false
		page_buttons_container.visible = false

		for page in tutorial_pages:
			page.visible = false
			page.process_mode = Node.PROCESS_MODE_DISABLED

		return

	menu_panel.visible = menu_open
	page_buttons_container.visible = menu_open

	for i in range(tutorial_pages.size()):
		var page := tutorial_pages[i]
		var active := i == current_page and not menu_open

		page.visible = active

		if active:
			page.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			page.process_mode = Node.PROCESS_MODE_DISABLED


func show_page() -> void:
	apply_menu_state()


func _on_page_button_pressed(page_index: int) -> void:
	if page_index >= 0 and page_index < tutorial_pages.size():
		current_page = page_index
		menu_open = false

		apply_menu_state()


func _on_minimize_pressed() -> void:
	set_ui_state(UIState.MINIMIZED)


func _on_tutorial_pressed() -> void:
	set_ui_state(UIState.TUTORIAL)

	menu_open = false

	for page in tutorial_pages:
		page.visible = false
		page.process_mode = Node.PROCESS_MODE_DISABLED

	apply_menu_state()


func _on_menu_pressed() -> void:
	menu_open = !menu_open
	apply_menu_state()


func _on_top_bar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - event.global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position + drag_offset
