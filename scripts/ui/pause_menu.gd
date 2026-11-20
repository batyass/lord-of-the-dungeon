extends CanvasLayer

@onready var resume_button: Button = $Backdrop/Panel/VBox/ResumeButton
@onready var restart_button: Button = $Backdrop/Panel/VBox/RestartButton
@onready var main_menu_button: Button = $Backdrop/Panel/VBox/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.focus_mode = Control.FOCUS_NONE
	restart_button.focus_mode = Control.FOCUS_NONE
	main_menu_button.focus_mode = Control.FOCUS_NONE
	resume_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	restart_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	main_menu_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func open() -> void:
	visible = true
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if visible:
			_on_resume_pressed()
		elif not get_tree().paused:
			open()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_economy()
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_economy()
	GameManager.change_state(GameManager.GameState.MENU)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")
