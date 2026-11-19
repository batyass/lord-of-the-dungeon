extends Control

@onready var btn_play: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnPlay
@onready var btn_options: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnOptions
@onready var btn_quit: Control = $CenterContainer/Panel/VBoxContainer/ButtonBox/BtnQuit

func _ready() -> void:
	if btn_play and is_instance_valid(btn_play):
		btn_play.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_selection.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_exit_pressed() -> void:
	_on_quit_pressed()
