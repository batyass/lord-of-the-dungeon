@tool
extends Control

signal pressed

@export_category("Settings")
@export var text: String = "NEW BUTTON"
@export var font_size: int = 26
@export var hover_pointer_offset: float = 16.0
@export var default_color: Color = Color(0.92, 0.93, 0.96, 1.0)
@export var hover_color: Color = Color(1.0, 0.76, 0.22, 1.0)

@export_category("ButtonElements")
@export var button: Button
@export var label_background_nodes: Array[Label]
@export var label_foreground_node: Label
@export var show_hover_pointer: bool = true
@export var hover_pointer: Control
@export var dark: bool = false

var editor_update_previous_text: String
var _is_hovered_or_focused: bool = false

func _ready() -> void:
	if dark:
		default_color = Color(0.15, 0.15, 0.18, 1.0)
		for label_node in label_background_nodes:
			if is_instance_valid(label_node):
				label_node.visible = false
	if is_instance_valid(hover_pointer):
		hover_pointer.pivot_offset = Vector2.ZERO
	set_text(text)
	_on_button_exited()
	
	if button:
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.mouse_entered.connect(_on_button_enter)
		button.mouse_exited.connect(_on_button_exited)
		button.focus_entered.connect(_on_button_enter)
		button.focus_exited.connect(_on_button_exited)
		button.pressed.connect(_on_button_pressed)
	
	focus_entered.connect(_on_focus_entered)
	resized.connect(_update_pointer_position)

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	if text != editor_update_previous_text:
		editor_update_previous_text = text
		set_text(text)

func _on_focus_entered() -> void:
	if button and is_instance_valid(button) and not button.has_focus():
		button.grab_focus()

func set_text(new_text: String) -> void:
	text = new_text
	for label_node in label_background_nodes:
		if is_instance_valid(label_node) and label_node.label_settings:
			label_node.label_settings = label_node.label_settings.duplicate()
			label_node.text = text
			label_node.label_settings.font_size = font_size
	
	if is_instance_valid(label_foreground_node) and label_foreground_node.label_settings:
		label_foreground_node.label_settings = label_foreground_node.label_settings.duplicate()
		label_foreground_node.text = text
		label_foreground_node.label_settings.font_size = font_size
		label_foreground_node.label_settings.font_color = hover_color if _is_hovered_or_focused else default_color
	
	_update_pointer_position()

func _update_pointer_position() -> void:
	if not is_instance_valid(hover_pointer) or not is_instance_valid(label_foreground_node) or not label_foreground_node.label_settings or not label_foreground_node.label_settings.font:
		return
	if hover_pointer.pivot_offset != Vector2.ZERO:
		hover_pointer.pivot_offset = Vector2.ZERO
	var text_width = label_foreground_node.label_settings.font.get_string_size(label_foreground_node.text, HORIZONTAL_ALIGNMENT_CENTER, -1, label_foreground_node.label_settings.font_size).x
	var ptr_w = hover_pointer.size.x * hover_pointer.scale.x
	var ptr_h = hover_pointer.size.y * hover_pointer.scale.y
	var text_start_x = (size.x - text_width) * 0.5
	var offset_x = maxf(hover_pointer_offset, 4.0)
	hover_pointer.position.x = text_start_x - ptr_w - offset_x
	hover_pointer.position.y = (size.y - ptr_h) * 0.5

func _on_button_enter():
	_is_hovered_or_focused = true
	if is_instance_valid(label_foreground_node) and label_foreground_node.label_settings:
		label_foreground_node.label_settings.font_color = hover_color
	if show_hover_pointer and is_instance_valid(hover_pointer):
		_update_pointer_position()
		hover_pointer.visible = true

func _on_button_exited():
	if button and button.has_focus():
		return
	_is_hovered_or_focused = false
	if is_instance_valid(label_foreground_node) and label_foreground_node.label_settings:
		label_foreground_node.label_settings.font_color = default_color
	if is_instance_valid(hover_pointer):
		hover_pointer.visible = false

func _on_button_pressed():
	pressed.emit()
