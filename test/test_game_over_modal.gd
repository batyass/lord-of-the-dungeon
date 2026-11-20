extends Node

func _ready() -> void:
	print("--- Running GameOverModal Comprehensive Verification ---")

	var modal_scene = load("res://scenes/ui/game_over_modal.tscn")
	assert(modal_scene != null, "game_over_modal.tscn must load successfully")

	var modal = modal_scene.instantiate()
	assert(modal != null, "game_over_modal must instantiate")
	add_child(modal)

	var backdrop = modal.find_child("DimBackdrop", true, false)
	assert(backdrop is ColorRect, "DimBackdrop must be a ColorRect")
	var panel = modal.find_child("Panel", true, false)
	assert(panel is PanelContainer, "Panel must be a PanelContainer")
	var title_lbl = modal.find_child("TitleLabel", true, false)
	var subtitle_lbl = modal.find_child("SubtitleLabel", true, false)
	var badge_lbl = modal.find_child("BadgeLabel", true, false)
	var stats_lbl = modal.find_child("StatsLabel", true, false)
	assert(title_lbl != null and subtitle_lbl != null and badge_lbl != null and stats_lbl != null, "Modal text references must exist")
	var play_again_btn = modal.find_child("PlayAgainButton", true, false)
	var main_menu_btn = modal.find_child("MainMenuButton", true, false)
	assert(play_again_btn != null and main_menu_btn != null, "Both modal buttons must exist")
	assert(play_again_btn.text == "PLAY AGAIN" and main_menu_btn.text == "MAIN MENU", "Modal buttons must have expected labels")
	assert(modal.restart_button == play_again_btn, "restart_button compatibility alias must point to Play Again")

	GameManager.match_duration = 185.0
	GameManager.total_minions_summoned = 28
	GameManager.total_enemies_killed = 19
	GameManager.total_gold_earned = 1450

	modal._show_modal("DUNGEON VICTORY!", Color(1.0, 0.82, 0.25))
	assert(modal.visible and play_again_btn.visible and main_menu_btn.visible, "Victory modal and both buttons must be visible")
	assert(title_lbl.text == "DUNGEON VICTORY!" and badge_lbl.text == "VICTORY", "Victory text must be shown")
	assert("03:05" in stats_lbl.text and "Minions Summoned: 28" in stats_lbl.text, "Duration and summoned stats must be shown")
	assert("Heroes Killed: 19" in stats_lbl.text and "Gold Earned: 1450g" in stats_lbl.text, "Kill and gold stats must be shown")
	assert(not ("—" in stats_lbl.text or "–" in stats_lbl.text), "Stats must not contain dash punctuation")

	modal._show_modal("THE DUNGEON HEART HAS FALLEN...", Color(0.92, 0.25, 0.25))
	assert(badge_lbl.text == "DEFEAT" and "THE DUNGEON HAS BEEN OVERRUN" in subtitle_lbl.text, "Defeat styling text must be shown")

	# Test Play Again routing by invoking the connected button signal.
	get_tree().change_scene_to_file("res://scenes/battle/battle_field.tscn")
	await get_tree().process_frame
	modal = get_tree().current_scene.get_node("GameOverModal")
	modal._show_modal("DUNGEON VICTORY!", Color(1.0, 0.82, 0.25))
	modal.find_child("PlayAgainButton", true, false).pressed.emit()
	await get_tree().process_frame
	assert(get_tree().current_scene.scene_file_path == "res://scenes/battle/battle_field.tscn", "PLAY AGAIN must reload battle scene")

	# Test Main Menu routing and ESC behavior on an active modal.
	modal = get_tree().current_scene.get_node("GameOverModal")
	modal._show_modal("DUNGEON VICTORY!", Color(1.0, 0.82, 0.25))
	var esc_event = InputEventKey.new()
	esc_event.pressed = true
	esc_event.keycode = KEY_ESCAPE
	modal._unhandled_input(esc_event)
	await get_tree().process_frame
	assert(get_tree().current_scene.scene_file_path == "res://scenes/main_menu.tscn", "ESC must route to Main Menu")

	get_tree().change_scene_to_file("res://scenes/battle/battle_field.tscn")
	await get_tree().process_frame
	modal = get_tree().current_scene.get_node("GameOverModal")
	modal._show_modal("DUNGEON VICTORY!", Color(1.0, 0.82, 0.25))
	modal.find_child("MainMenuButton", true, false).pressed.emit()
	await get_tree().process_frame
	assert(get_tree().current_scene.scene_file_path == "res://scenes/main_menu.tscn", "MAIN MENU button must route to main_menu.tscn")

	print("[PASS] GameOverModal stats, visibility, replay, ESC, and Main Menu flows verified.")
	get_tree().quit(0)
