extends Control

@onready var btn_back: Control = find_child("BtnBack", true, false)
@onready var btn_return: Control = btn_back

func _ready() -> void:
	if btn_back and is_instance_valid(btn_back):
		btn_back.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			var vp: Viewport = get_viewport()
			if vp:
				vp.set_input_as_handled()
			_return_to_main_menu()
	elif event.is_action_pressed("ui_cancel"):
		var vp: Viewport = get_viewport()
		if vp:
			vp.set_input_as_handled()
		_return_to_main_menu()

func _on_back_pressed() -> void:
	_return_to_main_menu()

func _on_button_pressed() -> void:
	_return_to_main_menu()

func _on_return_pressed() -> void:
	_return_to_main_menu()

func _return_to_main_menu() -> void:
	if not is_inside_tree():
		return
	var tree: SceneTree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/main_menu.tscn")
