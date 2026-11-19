extends Control

@onready var btn_normal: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnNormal
@onready var btn_hard: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnHard
@onready var btn_impossible: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnImpossible
@onready var btn_back: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnBack

func _ready() -> void:
	if btn_normal and is_instance_valid(btn_normal):
		btn_normal.grab_focus()

func _on_normal_pressed() -> void:
	_set_difficulty("normal")

func _on_hard_pressed() -> void:
	_set_difficulty("hard")

func _on_impossible_pressed() -> void:
	_set_difficulty("impossible")

func _set_difficulty(diff_name: String) -> void:
	var global_vars = get_node_or_null("/root/GlobalVariables")
	if global_vars:
		match diff_name:
			"normal":
				global_vars.current_difficulty = global_vars.difficulty.normal
			"hard":
				global_vars.current_difficulty = global_vars.difficulty.hard
			"impossible":
				global_vars.current_difficulty = global_vars.difficulty.impossible
			_:
				push_error("Unknown difficulty: %s" % diff_name)
				return
	get_tree().change_scene_to_file("res://scenes/level_selection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_return_pressed() -> void:
	_on_back_pressed()
