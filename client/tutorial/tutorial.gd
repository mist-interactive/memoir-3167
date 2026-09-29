extends Control

@onready var matchState: MatchState = $"../../../matchState"

@export var minimize_button: Button
@export var tutorial_button: Button
@export var menu_button: Button
@export var previous_page_button: Button
@export var next_page_button: Button

@export var panel: Panel
@export var top_bar: Panel

@export var page_buttons_container: Container

@export var tutorial_pages: Array[Control]
@export var page_buttons: Array[Button]

@export var page_moving_units_buttons: Array[Button]
@export var page_moving_units_page_targets: Array[Control]
@export var page_moving_units_return_pages: Array[Control]

@export var help_button_target_pages: Array[Control]

var navigation_return_page: Control = null

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

var cursor_normal: Texture2D
var cursor_hover: Texture2D
var cursor_drag: Texture2D
var cursor_clickable: Texture2D

func _ready() -> void:
	minimize_button.pressed.connect(_on_minimize_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	minimize_button.mouse_entered.connect(set_cursor_clickable)
	minimize_button.mouse_exited.connect(set_cursor_normal)

	tutorial_button.mouse_entered.connect(set_cursor_clickable)
	tutorial_button.mouse_exited.connect(set_cursor_normal)

	menu_button.mouse_entered.connect(set_cursor_clickable)
	menu_button.mouse_exited.connect(set_cursor_normal)
	
	previous_page_button.pressed.connect(_on_previous_page_button_pressed)
	next_page_button.pressed.connect(_on_next_page_button_pressed)

	previous_page_button.mouse_entered.connect(set_cursor_clickable)
	previous_page_button.mouse_exited.connect(set_cursor_normal)

	next_page_button.mouse_entered.connect(set_cursor_clickable)
	next_page_button.mouse_exited.connect(set_cursor_normal)

	for i in range(page_buttons.size()):
		page_buttons[i].pressed.connect(_on_page_button_pressed.bind(i))
		page_buttons[i].mouse_entered.connect(set_cursor_clickable)
		page_buttons[i].mouse_exited.connect(set_cursor_normal)

	for page in tutorial_pages:
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var rich_text_label: RichTextLabel = page.get_node("Text")
		rich_text_label.size = PAGE_SIZE
		rich_text_label.position = PAGE_POSITION
		rich_text_label.custom_minimum_size = PAGE_CUSTOM_MIN
		rich_text_label.custom_maximum_size = PAGE_CUSTOM_MAX
		
	for i in range(page_moving_units_buttons.size()):
		var button := page_moving_units_buttons[i]
		button.pressed.connect(
			_on_page_moving_units_button_pressed.bind(i)
		)
		button.mouse_entered.connect(set_cursor_clickable)
		button.mouse_exited.connect(set_cursor_normal)

	cursor_normal = load("res://assets/sprites/cursor/Normal-3.png")
	cursor_hover = load("res://assets/sprites/cursor/Move_2-3.png")
	cursor_drag = load("res://assets/sprites/cursor/Move_1-3.png")
	cursor_clickable = load("res://assets/sprites/cursor/Link-3.png")

	top_bar.gui_input.connect(_on_top_bar_input)
	top_bar.mouse_entered.connect(_on_top_bar_mouse_entered)
	top_bar.mouse_exited.connect(_on_top_bar_mouse_exited)

	set_cursor_normal()
	set_ui_state(UIState.MINIMIZED)

func _on_page_moving_units_button_pressed(button_index: int) -> void:
	if button_index < 0:
		return

	if button_index >= page_moving_units_page_targets.size():
		return

	if button_index >= page_moving_units_return_pages.size():
		return

	var target_page := page_moving_units_page_targets[button_index]
	var return_page := page_moving_units_return_pages[button_index]

	if target_page == null or return_page == null:
		return

	if not tutorial_pages.has(target_page):
		return

	if not tutorial_pages.has(return_page):
		return

	# Remember where this button came from.
	navigation_return_page = return_page

	# Jump to the manually assigned target page.
	current_page = tutorial_pages.find(target_page)
	menu_open = false
	apply_menu_state()

func _on_previous_page_button_pressed() -> void:
	if navigation_return_page != null:
		var return_index := tutorial_pages.find(navigation_return_page)

		if return_index != -1:
			current_page = return_index

		navigation_return_page = null
		apply_menu_state()
		return

	if current_page > 0:
		current_page -= 1
		apply_menu_state()

func _on_next_page_button_pressed() -> void:
	if navigation_return_page != null:
		var return_index := tutorial_pages.find(navigation_return_page)

		if return_index != -1:
			current_page = return_index

		navigation_return_page = null
		apply_menu_state()
		return

	if current_page < tutorial_pages.size() - 1:
		current_page += 1
		apply_menu_state()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_M:
			open_tutorial_for_current_phase()
			get_viewport().set_input_as_handled()

func open_tutorial_for_current_phase() -> void:
	var target_page := get_help_page_for_phase()

	if target_page == null:
		return

	if not tutorial_pages.has(target_page):
		return

	current_page = tutorial_pages.find(target_page)
	navigation_return_page = null
	menu_open = false
	set_ui_state(UIState.TUTORIAL)

func get_help_page_for_phase() -> Control:
	var phase_index := int(matchState.phase)

	if phase_index < 0 or phase_index >= help_button_target_pages.size():
		return null

	return help_button_target_pages[phase_index]

func set_cursor_normal() -> void:
	Input.set_custom_mouse_cursor(
		cursor_normal,
		Input.CURSOR_ARROW,
		Vector2(8, 8)
	)

func set_cursor_hover() -> void:
	Input.set_custom_mouse_cursor(
		cursor_hover,
		Input.CURSOR_ARROW,
		Vector2(32, 32)
	)

func set_cursor_drag() -> void:
	Input.set_custom_mouse_cursor(
		cursor_drag,
		Input.CURSOR_ARROW,
		Vector2(32, 32)
	)

func set_cursor_clickable() -> void:
	Input.set_custom_mouse_cursor(
		cursor_clickable,
		Input.CURSOR_ARROW,
		Vector2(32, 8)
	)

func _on_top_bar_mouse_entered() -> void:
	if not dragging:
		set_cursor_hover()

func _on_top_bar_mouse_exited() -> void:
	if not dragging:
		set_cursor_normal()

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

	menu_open = false

	for page in tutorial_pages:
		page.visible = false
		page.process_mode = Node.PROCESS_MODE_DISABLED

	for button in page_buttons:
		button.visible = false

	set_cursor_normal()

func apply_menu_state() -> void:
	if current_state != UIState.TUTORIAL:
		page_buttons_container.visible = false

		for page in tutorial_pages:
			page.visible = false
			page.process_mode = Node.PROCESS_MODE_DISABLED

		return

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
		navigation_return_page = null
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
				set_cursor_drag()
			else:
				dragging = false
				set_cursor_hover()
	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position + drag_offset
