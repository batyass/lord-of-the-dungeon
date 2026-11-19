extends CanvasLayer

@onready var panel_container: PanelContainer = find_child("Panel", true, false)
@onready var title_label: Label = find_child("TitleLabel", true, false)
@onready var subtitle_label: Label = find_child("SubtitleLabel", true, false)
@onready var badge_label: Label = find_child("BadgeLabel", true, false)
@onready var stats_panel: PanelContainer = find_child("StatsPanel", true, false)
@onready var stats_label: Label = find_child("StatsLabel", true, false)
@onready var play_again_button: Button = find_child("PlayAgainButton", true, false)
@onready var main_menu_button: Button = find_child("MainMenuButton", true, false)
@onready var restart_button: Button = play_again_button

var _panel_style: StyleBoxFlat
var _stats_style: StyleBoxFlat
var _play_btn_style: StyleBoxFlat

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if play_again_button == null:
		play_again_button = find_child("RestartButton", true, false)
	restart_button = play_again_button

	if panel_container:
		var base_panel = panel_container.get_theme_stylebox("panel")
		if base_panel:
			_panel_style = base_panel.duplicate() as StyleBoxFlat
			panel_container.add_theme_stylebox_override("panel", _panel_style)

	if stats_panel:
		var base_stats = stats_panel.get_theme_stylebox("panel")
		if base_stats:
			_stats_style = base_stats.duplicate() as StyleBoxFlat
			stats_panel.add_theme_stylebox_override("panel", _stats_style)

	if play_again_button:
		play_again_button.focus_mode = Control.FOCUS_NONE
		play_again_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var base_btn = play_again_button.get_theme_stylebox("normal")
		if base_btn:
			_play_btn_style = base_btn.duplicate() as StyleBoxFlat
			play_again_button.add_theme_stylebox_override("normal", _play_btn_style)

	if main_menu_button:
		main_menu_button.focus_mode = Control.FOCUS_NONE
		main_menu_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	if play_again_button and not play_again_button.pressed.is_connected(_on_play_again_pressed):
		play_again_button.pressed.connect(_on_play_again_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_pressed):
		main_menu_button.pressed.connect(_on_main_menu_pressed)

	if Events and Events.has_signal("game_state_changed"):
		Events.game_state_changed.connect(_on_game_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		_on_main_menu_pressed()

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	if new_state == GameManager.GameState.VICTORY:
		_show_modal("DUNGEON VICTORY!", Color(1.0, 0.82, 0.25))
	elif new_state == GameManager.GameState.DEFEAT:
		_show_modal("THE DUNGEON HEART HAS FALLEN...", Color(0.92, 0.25, 0.25))

func _show_modal(title_text: String = "", title_color: Color = Color.WHITE) -> void:
	visible = true

	var is_victory: bool = true
	if title_text != "":
		is_victory = not (title_text.to_upper().contains("FALLEN") or title_text.to_upper().contains("DEFEAT"))
	elif GameManager.current_state == GameManager.GameState.DEFEAT:
		is_victory = false

	if is_victory:
		_apply_victory_theme(title_text, title_color)
	else:
		_apply_defeat_theme(title_text, title_color)

	_update_stats_display()

func _apply_victory_theme(custom_title: String, custom_color: Color) -> void:
	var gold_primary: Color = Color(1.0, 0.82, 0.25, 1.0)
	var gold_amber: Color = Color(0.95, 0.72, 0.22, 1.0)
	var gold_sub: Color = Color(0.92, 0.78, 0.45, 0.95)

	if title_label:
		title_label.text = custom_title if custom_title != "" else "DUNGEON VICTORY!"
		var final_col = custom_color if custom_color != Color.WHITE else gold_primary
		title_label.add_theme_color_override("font_color", final_col)
	if badge_label:
		badge_label.text = "VICTORY"
		badge_label.add_theme_color_override("font_color", gold_amber)
	if subtitle_label:
		subtitle_label.text = "THE SURFACE INVADERS HAVE BEEN CRUSHED"
		subtitle_label.add_theme_color_override("font_color", gold_sub)

	if _panel_style:
		_panel_style.border_color = Color(0.95, 0.72, 0.22, 0.85)
	if _stats_style:
		_stats_style.border_color = Color(0.95, 0.72, 0.22, 0.45)
	if _play_btn_style:
		_play_btn_style.border_color = Color(0.95, 0.72, 0.22, 0.85)
		_play_btn_style.bg_color = Color(0.12, 0.14, 0.20, 0.95)
	if play_again_button:
		play_again_button.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65, 1.0))

func _apply_defeat_theme(custom_title: String, custom_color: Color) -> void:
	var crimson_primary: Color = Color(0.92, 0.25, 0.25, 1.0)
	var crimson_accent: Color = Color(0.85, 0.22, 0.25, 1.0)
	var crimson_sub: Color = Color(0.85, 0.45, 0.45, 0.95)

	if title_label:
		title_label.text = custom_title if custom_title != "" else "THE DUNGEON HEART HAS FALLEN..."
		var final_col = custom_color if custom_color != Color.WHITE else crimson_primary
		title_label.add_theme_color_override("font_color", final_col)
	if badge_label:
		badge_label.text = "DEFEAT"
		badge_label.add_theme_color_override("font_color", crimson_accent)
	if subtitle_label:
		subtitle_label.text = "THE DUNGEON HAS BEEN OVERRUN"
		subtitle_label.add_theme_color_override("font_color", crimson_sub)

	if _panel_style:
		_panel_style.border_color = Color(0.85, 0.22, 0.25, 0.80)
	if _stats_style:
		_stats_style.border_color = Color(0.85, 0.22, 0.25, 0.45)
	if _play_btn_style:
		_play_btn_style.border_color = Color(0.85, 0.25, 0.25, 0.85)
		_play_btn_style.bg_color = Color(0.16, 0.08, 0.10, 0.95)
	if play_again_button:
		play_again_button.add_theme_color_override("font_color", Color(1.0, 0.75, 0.75, 1.0))

func _update_stats_display() -> void:
	var mins: int = int(GameManager.match_duration) / 60
	var secs: int = int(GameManager.match_duration) % 60

	if stats_label:
		stats_label.text = "BATTLE SUMMARY\n\n• Match Duration: %02d:%02d\n• Minions Summoned: %d\n• Heroes Killed: %d\n• Gold Earned: %dg" % [
			mins, secs,
			GameManager.total_minions_summoned,
			GameManager.total_enemies_killed,
			GameManager.total_gold_earned
		]

func _on_play_again_pressed() -> void:
	Engine.time_scale = 1.0
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_economy()
	get_tree().reload_current_scene()
	GameManager.start_battle()

func _on_restart_pressed() -> void:
	_on_play_again_pressed()

func _on_main_menu_pressed() -> void:
	Engine.time_scale = 1.0
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_economy()
	GameManager.change_state(GameManager.GameState.MENU)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")
