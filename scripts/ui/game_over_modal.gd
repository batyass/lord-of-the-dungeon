extends CanvasLayer

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var stats_label: Label = $Panel/VBox/StatsLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton

func _ready() -> void:
	visible = false
	Events.game_state_changed.connect(_on_game_state_changed)
	restart_button.pressed.connect(_on_restart_pressed)

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	if new_state == GameManager.GameState.VICTORY:
		_show_modal("VICTOIRE DU DONJON !", Color(1.0, 0.8, 0.2))
	elif new_state == GameManager.GameState.DEFEAT:
		_show_modal("LE COEUR DU DONJON EST BRISÉ...", Color(0.9, 0.2, 0.2))

func _show_modal(title_text: String, title_color: Color) -> void:
	visible = true
	title_label.text = title_text
	title_label.set("theme_override_colors/font_color", title_color)
	
	var mins = int(GameManager.match_duration) / 60
	var secs = int(GameManager.match_duration) % 60
	
	stats_label.text = "BILAN DE BATAILLE :\n• Durée : %02d:%02d\n• Sbires invoqués : %d\n• Héros éliminés : %d\n• Or total accumulé : %dg" % [
		mins, secs,
		GameManager.total_minions_summoned,
		GameManager.total_enemies_killed,
		GameManager.total_gold_earned
	]

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	GameManager.start_battle()
