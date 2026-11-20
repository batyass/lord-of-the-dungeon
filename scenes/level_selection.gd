extends Control

@onready var btn_level_1: Control = $CenterContainer/Panel/VBoxContainer/LevelCards/CardLevel1/VBox/BtnLevel1
@onready var btn_level_2: Control = $CenterContainer/Panel/VBoxContainer/LevelCards/CardLevel2/VBox/BtnLevel2
@onready var btn_level_3: Control = $CenterContainer/Panel/VBoxContainer/LevelCards/CardLevel3/VBox/BtnLevel3
@onready var btn_back: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnBack

func _ready() -> void:
	if btn_level_1 and is_instance_valid(btn_level_1):
		btn_level_1.grab_focus()

func _on_level_1_pressed() -> void:
	_select_level(1)

func _on_level_2_pressed() -> void:
	_select_level(2)

func _on_level_3_pressed() -> void:
	_select_level(3)

func _select_level(lvl: int) -> void:
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr:
		wave_mgr.current_level = lvl
		wave_mgr.start_level(lvl)
	var econ_mgr = get_node_or_null("/root/EconomyManager")
	if econ_mgr and econ_mgr.has_method("reset_for_level"):
		econ_mgr.reset_for_level()
	var music_mgr = get_node_or_null("/root/MusicManager")
	if music_mgr and music_mgr.has_method("play_level"):
		music_mgr.play_level(lvl)
	get_tree().change_scene_to_file("res://scenes/battle/battle_field.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_selection.tscn")
