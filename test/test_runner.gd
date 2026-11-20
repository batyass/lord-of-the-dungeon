extends Node

func _ready() -> void:
	print("--- Running Lord of the Dungeon Full Integration Test ---")
	
	# Verify Autoloads are present
	assert(has_node("/root/GlobalVariables"), "GlobalVariables autoload must exist")
	assert(has_node("/root/WaveManager"), "WaveManager autoload must exist")
	assert(has_node("/root/MusicManager"), "MusicManager autoload must exist")
	assert(has_node("/root/GameManager"), "GameManager autoload must exist")
	assert(has_node("/root/EconomyManager"), "EconomyManager autoload must exist")
	print("[PASS] Autoloads verified.")
	
	# Test 1: Parallax Background
	var bg_scene = load("res://scenes/menu_parallax_background.tscn")
	assert(bg_scene != null, "Parallax background scene must load")
	var bg_inst = bg_scene.instantiate()
	assert(bg_inst != null, "Parallax background must instantiate")
	add_child(bg_inst)
	print("[PASS] Test 1: Parallax background loaded and instantiated.")
	bg_inst.queue_free()
	
	# Test 2: Main Menu
	var main_scene = load("res://scenes/main_menu.tscn")
	assert(main_scene != null, "Main menu scene must load")
	var main_inst = main_scene.instantiate()
	assert(main_inst != null, "Main menu must instantiate")
	add_child(main_inst)
	
	var title = main_inst.find_child("TitleLabel", true, false)
	assert(title != null, "TitleLabel must exist")
	assert(title.text == "Lord of the Dungeon", "Title must be 'Lord of the Dungeon'")
	
	var btn_play = main_inst.find_child("BtnPlay", true, false)
	var btn_options = main_inst.find_child("BtnOptions", true, false)
	var btn_quit = main_inst.find_child("BtnQuit", true, false)
	assert(btn_play != null, "BtnPlay must exist")
	assert(btn_options != null, "BtnOptions must exist")
	assert(btn_quit != null, "BtnQuit must exist")
	assert(btn_play.text == "Play", "Play button text must match")
	assert(btn_options.text == "Options", "Options button text must match")
	assert(btn_quit.text == "Quit", "Quit button text must match")
	print("[PASS] Test 2: Main Start Menu verified.")
	main_inst.queue_free()
	
	# Test 3: Difficulty Selection & State Wiring
	var diff_scene = load("res://scenes/difficulty_selection.tscn")
	assert(diff_scene != null, "Difficulty selection scene must load")
	var diff_inst = diff_scene.instantiate()
	assert(diff_inst != null, "Difficulty selection must instantiate")
	add_child(diff_inst)
	
	var btn_normal = diff_inst.find_child("BtnNormal", true, false)
	var btn_hard = diff_inst.find_child("BtnHard", true, false)
	var btn_impossible = diff_inst.find_child("BtnImpossible", true, false)
	var btn_back_diff = diff_inst.find_child("BtnBack", true, false)
	assert(btn_normal != null, "BtnNormal must exist")
	assert(btn_hard != null, "BtnHard must exist")
	assert(btn_impossible != null, "BtnImpossible must exist")
	assert(btn_back_diff != null, "BtnBack must exist in Difficulty Selection")
	
	# Test difficulty state setting directly
	var global_vars = get_node("/root/GlobalVariables")
	diff_inst._set_difficulty("normal")
	assert(global_vars.current_difficulty == global_vars.difficulty.normal, "Normal difficulty set")
	diff_inst._set_difficulty("hard")
	assert(global_vars.current_difficulty == global_vars.difficulty.hard, "Hard difficulty set")
	diff_inst._set_difficulty("impossible")
	assert(global_vars.current_difficulty == global_vars.difficulty.impossible, "Impossible difficulty set")
	print("[PASS] Test 3: Difficulty Selection and GlobalVariables wiring verified.")
	diff_inst.queue_free()
	
	# Test 4: Level Selection & State Wiring
	var lvl_scene = load("res://scenes/level_selection.tscn")
	assert(lvl_scene != null, "Level selection scene must load")
	var lvl_inst = lvl_scene.instantiate()
	assert(lvl_inst != null, "Level selection must instantiate")
	add_child(lvl_inst)
	
	var btn_lvl1 = lvl_inst.find_child("BtnLevel1", true, false)
	var btn_lvl2 = lvl_inst.find_child("BtnLevel2", true, false)
	var btn_lvl3 = lvl_inst.find_child("BtnLevel3", true, false)
	var btn_back_lvl = lvl_inst.find_child("BtnBack", true, false)
	assert(btn_lvl1 != null, "BtnLevel1 must exist")
	assert(btn_lvl2 != null, "BtnLevel2 must exist")
	assert(btn_lvl3 != null, "BtnLevel3 must exist")
	assert(btn_back_lvl != null, "BtnBack must exist in Level Selection")
	
	var wave_mgr = get_node("/root/WaveManager")
	var music_mgr = get_node("/root/MusicManager")
	
	lvl_inst._select_level(2)
	assert(wave_mgr.current_level == 2, "WaveManager.current_level must be 2")
	assert(music_mgr.current_level_playing == 2, "MusicManager.current_level_playing must be 2")
	
	lvl_inst._select_level(3)
	assert(wave_mgr.current_level == 3, "WaveManager.current_level must be 3")
	assert(music_mgr.current_level_playing == 3, "MusicManager.current_level_playing must be 3")
	
	lvl_inst._select_level(1)
	assert(wave_mgr.current_level == 1, "WaveManager.current_level must be 1")
	assert(music_mgr.current_level_playing == 1, "MusicManager.current_level_playing must be 1")
	print("[PASS] Test 4: Level Selection and WaveManager/MusicManager wiring verified.")
	lvl_inst.queue_free()
	
	# Test 5: Battle Field scene loading
	var battle_scene = load("res://scenes/battle/battle_field.tscn")
	assert(battle_scene != null, "Battle field scene must load")
	var battle_inst = battle_scene.instantiate()
	assert(battle_inst != null, "Battle field must instantiate")
	add_child(battle_inst)
	var pause_menu = battle_inst.get_node_or_null("PauseMenu")
	assert(pause_menu != null, "Battle field must include PauseMenu")
	assert(pause_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu must process while paused")
	var pause_buttons: Array[Button] = [
		pause_menu.find_child("ResumeButton", true, false),
		pause_menu.find_child("RestartButton", true, false),
		pause_menu.find_child("MainMenuButton", true, false)
	]
	assert(pause_buttons[0].text == "RESUME", "Pause menu must include Resume")
	assert(pause_buttons[1].text == "RESTART", "Pause menu must include Restart")
	assert(pause_buttons[2].text == "QUIT TO MAIN MENU", "Pause menu must include Main Menu")
	pause_menu.open()
	assert(get_tree().paused, "Opening pause menu must pause the tree")
	var esc_event = InputEventKey.new()
	esc_event.pressed = true
	esc_event.keycode = KEY_ESCAPE
	battle_inst._unhandled_input(esc_event)
	assert(pause_menu.visible and get_tree().paused, "Escape must open the pause menu and pause gameplay")
	pause_menu._on_resume_pressed()
	assert(not get_tree().paused and not pause_menu.visible, "Resume must unpause and hide the menu")
	pause_menu.open()
	assert(get_tree().paused, "Pause menu can be opened again")
	pause_menu._on_main_menu_pressed()
	assert(not get_tree().paused, "Main Menu action must clear pause state")
	pause_menu.queue_free()
	battle_inst.queue_free()
	print("[PASS] Test 5: Battle field and pause menu verified.")
	
	# Test 6: HUD Lane Selector Component, Keyboard Shortcuts & Signal Verification
	var hud_scene = load("res://scenes/ui/hud.tscn")
	assert(hud_scene != null, "HUD scene must load")
	var hud_inst = hud_scene.instantiate()
	assert(hud_inst != null, "HUD scene must instantiate")
	add_child(hud_inst)
	
	var lane_selector = hud_inst.find_child("LaneSelector", true, false)
	assert(lane_selector != null, "LaneSelector container must exist")
	
	var btn_top = hud_inst.find_child("BtnLaneTop", true, false)
	var btn_mid = hud_inst.find_child("BtnLaneMid", true, false)
	var btn_bot = hud_inst.find_child("BtnLaneBot", true, false)
	var active_badge = hud_inst.find_child("ActiveLaneBadge", true, false)
	
	assert(btn_top != null, "BtnLaneTop must exist")
	assert(btn_mid != null, "BtnLaneMid must exist")
	assert(btn_bot != null, "BtnLaneBot must exist")
	assert(active_badge != null, "ActiveLaneBadge must exist")
	
	# Default lane must be Mid (index 1)
	assert(hud_inst.current_lane == 1, "Default lane must be 1 (Mid)")
	assert(hud_inst.get_selected_lane() == 1, "get_selected_lane() must return 1")
	assert(btn_mid.button_pressed == true, "BtnLaneMid must be pressed by default")
	assert("MID" in active_badge.text, "Badge must display MID by default")
	
	# Signal tracking
	var signal_received_hud: Array = []
	var signal_received_events: Array = []
	hud_inst.lane_changed.connect(func(idx): signal_received_hud.append(idx))
	Events.lane_changed.connect(func(idx): signal_received_events.append(idx))
	
	# Test direct selection: Top (0)
	hud_inst.select_lane(0)
	assert(hud_inst.current_lane == 0, "Current lane must be 0 (Top)")
	assert(btn_top.button_pressed == true, "BtnLaneTop must be pressed")
	assert("TOP" in active_badge.text, "Badge must display TOP")
	assert(signal_received_hud.has(0), "hud.lane_changed must emit 0")
	assert(signal_received_events.has(0), "Events.lane_changed must emit 0")
	
	# Test direct selection: Bot (2)
	hud_inst.select_lane(2)
	assert(hud_inst.current_lane == 2, "Current lane must be 2 (Bot)")
	assert(btn_bot.button_pressed == true, "BtnLaneBot must be pressed")
	assert("BOT" in active_badge.text, "Badge must display BOT")
	assert(signal_received_hud.has(2), "hud.lane_changed must emit 2")
	
	# Test Keyboard Shortcuts: [Q], [W], [E]
	var evt_q = InputEventKey.new()
	evt_q.pressed = true
	evt_q.keycode = KEY_Q
	hud_inst._unhandled_input(evt_q)
	assert(hud_inst.current_lane == 0, "Key Q must select Top lane (0)")
	
	var evt_w = InputEventKey.new()
	evt_w.pressed = true
	evt_w.keycode = KEY_W
	hud_inst._unhandled_input(evt_w)
	assert(hud_inst.current_lane == 1, "Key W must select Mid lane (1)")
	
	var evt_e = InputEventKey.new()
	evt_e.pressed = true
	evt_e.keycode = KEY_E
	hud_inst._unhandled_input(evt_e)
	assert(hud_inst.current_lane == 2, "Key E must select Bot lane (2)")
	
	# Test Arrow Keys: [Up] / [Down]
	var evt_up = InputEventKey.new()
	evt_up.pressed = true
	evt_up.keycode = KEY_UP
	hud_inst._unhandled_input(evt_up)
	assert(hud_inst.current_lane == 1, "Key Up from Bot (2) must move to Mid (1)")
	
	hud_inst._unhandled_input(evt_up)
	assert(hud_inst.current_lane == 0, "Key Up from Mid (1) must move to Top (0)")
	
	hud_inst._unhandled_input(evt_up)
	assert(hud_inst.current_lane == 0, "Key Up at Top (0) must remain at Top (0)")
	
	var evt_down = InputEventKey.new()
	evt_down.pressed = true
	evt_down.keycode = KEY_DOWN
	hud_inst._unhandled_input(evt_down)
	assert(hud_inst.current_lane == 1, "Key Down from Top (0) must move to Mid (1)")
	
	hud_inst._unhandled_input(evt_down)
	assert(hud_inst.current_lane == 2, "Key Down from Mid (1) must move to Bot (2)")
	
	hud_inst._unhandled_input(evt_down)
	assert(hud_inst.current_lane == 2, "Key Down at Bot (2) must remain at Bot (2)")
	
	# Verify Top Bar symmetrical layout and dark fantasy stone panels
	var player_panel = hud_inst.find_child("PlayerHPContainer", true, false)
	var center_panel = hud_inst.find_child("CenterPanel", true, false)
	var enemy_panel = hud_inst.find_child("EnemyHPContainer", true, false)
	assert(player_panel != null, "PlayerHPContainer must exist in TopBar")
	assert(center_panel != null, "CenterPanel must exist in TopBar")
	assert(enemy_panel != null, "EnemyHPContainer must exist in TopBar")
	
	var dungeon_panel_res = load("res://UI/dungeon_panel.tres")
	assert(player_panel.get_theme_stylebox("panel") == dungeon_panel_res, "PlayerHPContainer must use UI/dungeon_panel.tres")
	assert(center_panel.get_theme_stylebox("panel") == dungeon_panel_res, "CenterPanel must use UI/dungeon_panel.tres")
	assert(enemy_panel.get_theme_stylebox("panel") == dungeon_panel_res, "EnemyHPContainer must use UI/dungeon_panel.tres")
	
	# Verify Player Base ('Underworld Dungeon')
	var player_title = player_panel.find_child("TitleLabel", true, false)
	assert(player_title != null and player_title.text == "Underworld Dungeon", "Player Base title must be 'Underworld Dungeon'")
	assert(hud_inst.player_hp_bar != null and hud_inst.player_hp_bar.max_value == 2500, "Player HP bar must have max 2500")
	assert(hud_inst.player_hp_label != null and hud_inst.player_hp_label.text == "2500 / 2500 HP", "Player HP label must show '2500 / 2500 HP'")
	
	# Verify Enemy Base ('Celestial Portal')
	var enemy_title = enemy_panel.find_child("TitleLabel", true, false)
	assert(enemy_title != null and enemy_title.text == "Celestial Portal", "Enemy Base title must be 'Celestial Portal'")
	assert(hud_inst.enemy_hp_bar != null and hud_inst.enemy_hp_bar.max_value == 2500, "Enemy HP bar must have max 2500")
	assert(hud_inst.enemy_hp_label != null and hud_inst.enemy_hp_label.text == "2500 / 2500 HP", "Enemy HP label must show '2500 / 2500 HP'")
	
	# Verify Center Panel (Level name, Wave indicator, Gold counter)
	assert(hud_inst.level_label != null, "Level label must exist")
	assert(hud_inst.wave_label != null and "WAVE 1" in hud_inst.wave_label.text, "Wave label must show WAVE 1")
	assert(hud_inst.gold_label != null and "100g" in hud_inst.gold_label.text, "Gold label must show treasury")
	
	# Verify Level, Wave, and Difficulty visual elements
	assert(hud_inst.level_tag != null, "LevelTag must exist")
	assert(hud_inst.wave_tag != null, "WaveTag must exist")
	assert(hud_inst.difficulty_label != null, "DifficultyLabel must exist")
	assert(hud_inst.difficulty_tag != null, "DifficultyTag must exist")
	assert(hud_inst.level_label.text == "The Underworld", "Level label must display 'The Underworld' for Level 1")
	assert("●" in hud_inst.wave_tag.text, "WaveTag must include pip indicators")
	assert(hud_inst.difficulty_label.text == "IMPOSSIBLE", "DifficultyLabel must display current difficulty (IMPOSSIBLE)")
	global_vars.current_difficulty = global_vars.difficulty.normal
	hud_inst._update_difficulty_display()
	assert(hud_inst.difficulty_label.text == "NORMAL", "DifficultyLabel must update to NORMAL")

	# Verify Banner & Transition components
	assert(hud_inst.wave_banner != null, "WaveBanner must exist")
	assert(hud_inst.wave_banner.mouse_filter == Control.MOUSE_FILTER_IGNORE, "WaveBanner mouse filter must be IGNORE")
	assert(hud_inst.level_transition != null, "LevelTransition must exist")
	assert(hud_inst.level_transition.mouse_filter == Control.MOUSE_FILTER_IGNORE, "LevelTransition mouse filter must be IGNORE")

	# Test Level Transition & Thematic Color updates
	Events.level_changed.emit(2, "The Surface")
	assert(hud_inst.level_label.text == "The Surface", "LevelLabel must update to 'The Surface'")
	assert(hud_inst.level_label.get_theme_color("font_color") == hud_inst.LEVEL_THEMES[2]["color"], "Level 2 must use emerald color")
	assert(hud_inst.level_transition.visible == true, "Level transition banner must become visible")

	# Test Wave Started & Wave Intro Banner
	Events.wave_started.emit(2, "WAVE 2: ELITE BATTALION")
	assert(hud_inst.wave_label.text == "WAVE 2: ELITE BATTALION", "WaveLabel must update")
	assert("● ● ○" in hud_inst.wave_tag.text, "WaveTag must show 2 active pips for Wave 2")
	assert(hud_inst.wave_banner.visible == true, "Wave banner must become visible")
	
	# Test Base Damaged signals for both teams
	Events.base_damaged.emit(GameManager.Team.PLAYER, 1950, 2500)
	assert(hud_inst.player_hp_bar.value == 1950, "Player HP bar must reflect damage")
	assert(hud_inst.player_hp_label.text == "1950 / 2500 HP", "Player HP label must reflect damage")
	
	Events.base_damaged.emit(GameManager.Team.ENEMY, 2200, 2500)
	assert(hud_inst.enemy_hp_bar.value == 2200, "Enemy HP bar must reflect damage")
	assert(hud_inst.enemy_hp_label.text == "2200 / 2500 HP", "Enemy HP label must reflect damage")
	
	# Verify Bottom Bar controls (Unit cards & Meteor button)
	assert(hud_inst.card_bat != null and hud_inst.card_bat.name_label.text == "Demonic Eye", "CardBat must display 'Demonic Eye'")
	assert(hud_inst.card_skeleton != null and hud_inst.card_skeleton.name_label.text == "Skeleton Warrior", "CardSkeleton must display 'Skeleton Warrior'")
	assert(hud_inst.card_golem != null and hud_inst.card_golem.name_label.text == "Magma Worm", "CardGolem must display 'Magma Worm'")
	assert(hud_inst.card_bat.cost_label.text == "20g", "CardBat cost must be 20g")
	assert(hud_inst.card_skeleton.cost_label.text == "50g", "CardSkeleton cost must be 50g")
	assert(hud_inst.card_golem.cost_label.text == "120g", "CardGolem cost must be 120g")
	assert(hud_inst.card_bat.cooldown_bar != null, "Unit card cooldown bar must exist")
	assert(hud_inst.meteor_button != null and "[SPACE]" in hud_inst.meteor_button.text, "Meteor button must show [SPACE]")
	
	hud_inst.queue_free()
	print("[PASS] Test 6: HUD redesign, stone panels, base health tracking & lane selector verified.")
	
	# Test 7: Battle Field Lane Calibration and Base Positions
	var bf_inst = battle_scene.instantiate()
	assert(bf_inst != null, "Battle field must instantiate")
	add_child(bf_inst)
	assert(bf_inst.LEVEL_LANE_Y[1] == [430.0, 452.0, 475.0], "Level 1 lane Y must be calibrated to [430.0, 452.0, 475.0]")
	assert(bf_inst.LEVEL_LANE_Y[2] == [445.0, 465.0, 485.0], "Level 2 lane Y must be calibrated to [445.0, 465.0, 485.0]")
	assert(bf_inst.LEVEL_LANE_Y[3] == [420.0, 438.0, 456.0], "Level 3 lane Y must be calibrated to [420.0, 438.0, 456.0]")
	var p_base = bf_inst.get_node_or_null("Bases/PlayerBase")
	var e_base = bf_inst.get_node_or_null("Bases/EnemyBase")
	assert(p_base != null and p_base.global_position.y == 452.0, "PlayerBase position.y must align with level 1 road center (452)")
	assert(e_base != null and e_base.global_position.y == 452.0, "EnemyBase position.y must align with level 1 road center (452)")
	
	# Verify base dynamic realignment across levels
	bf_inst._realign_bases_for_level(2)
	assert(p_base.global_position.y == 465.0, "PlayerBase must realign to level 2 road center (465)")
	bf_inst._realign_bases_for_level(3)
	assert(p_base.global_position.y == 438.0, "PlayerBase must realign to level 3 road center (438)")
	
	# Verify player lane selection response
	bf_inst._on_player_lane_changed(2)
	assert(bf_inst.selected_player_lane == 2, "Selected player lane must update to 2")
	bf_inst._on_player_lane_changed(0)
	assert(bf_inst.selected_player_lane == 0, "Selected player lane must update to 0")
	
	bf_inst.queue_free()
	print("[PASS] Test 7: Battle Field lane calibration and base positions verified.")

	# Test 8: Unit Resource Localization (100% English)
	var expected_units = {
		"res://resources/units/bat.tres": "Demonic Eye",
		"res://resources/units/skeleton.tres": "Skeleton Warrior",
		"res://resources/units/golem.tres": "Magma Worm",
		"res://resources/units/enemy_warrior.tres": "Crusader Knight",
		"res://resources/units/enemy_archer.tres": "Royal Huntress",
		"res://resources/units/enemy_boss.tres": "Conqueror King"
	}
	for res_path in expected_units:
		var u_res = load(res_path)
		assert(u_res != null, "Unit resource %s must load" % res_path)
		assert(u_res.display_name == expected_units[res_path], "Unit %s display_name must be '%s', got '%s'" % [res_path, expected_units[res_path], u_res.display_name])
	print("[PASS] Test 8: Unit resource display names verified 100% English.")
	
	# Test 9: Menu Button Pointer Overlap & Positioning Verification
	var btn_test_scene = load("res://scenes/ui/menu_button.tscn")
	assert(btn_test_scene != null, "menu_button.tscn must load")
	var test_btn = btn_test_scene.instantiate()
	test_btn.size = Vector2(280, 44)
	add_child(test_btn)
	var test_strings = ["SELECT", "Play", "Options", "Normal", "The Underworld", "Click here to return to the menu"]
	for s in test_strings:
		test_btn.set_text(s)
		test_btn._on_button_enter()
		var ptr = test_btn.hover_pointer
		var lbl = test_btn.label_foreground_node
		var fsize = lbl.label_settings.font_size
		var text_w = lbl.label_settings.font.get_string_size(lbl.text, HORIZONTAL_ALIGNMENT_CENTER, -1, fsize).x
		var text_start_x = (test_btn.size.x - text_w) * 0.5
		var ptr_w = ptr.size.x * ptr.scale.x
		var ptr_right = ptr.position.x + ptr_w
		assert(ptr_right <= text_start_x, "Pointer right edge must not exceed text_start_x for text '%s'" % s)
		assert(text_start_x - ptr_right >= 4.0, "Pointer margin must be at least 4.0px")
		test_btn._on_button_exited()
	test_btn.queue_free()
	print("[PASS] Test 9: Menu button sword pointer positioning and zero-overlap verified.")
	
	# Test 10: Special Attack (Meteor) Dynamic Scaling & Cooldown Verification
	var expected_reg_dmg = {
		1: [90, 99, 108],
		2: [120, 132, 144],
		3: [150, 165, 180]
	}
	var expected_boss_dmg = {
		1: [95, 109, 124],
		2: [110, 126, 143],
		3: [125, 144, 163]
	}
	var expected_cds = {
		1: [22.0, 25.0, 28.0],
		2: [24.0, 27.0, 30.0],
		3: [26.0, 29.0, 32.0]
	}

	for lvl in range(1, 4):
		for diff in range(3):
			var reg_val = wave_mgr.get_meteor_damage(false, lvl, diff)
			var boss_val = wave_mgr.get_meteor_damage(true, lvl, diff)
			var cd_val = wave_mgr.get_meteor_cooldown(lvl, diff)
			assert(reg_val == expected_reg_dmg[lvl][diff], "L%d D%d reg dmg mismatch" % [lvl, diff])
			assert(boss_val == expected_boss_dmg[lvl][diff], "L%d D%d boss dmg mismatch" % [lvl, diff])
			assert(is_equal_approx(cd_val, expected_cds[lvl][diff]), "L%d D%d cd mismatch" % [lvl, diff])

	# Test BattleField live application of scaled meteor damage
	var bf_test = battle_scene.instantiate()
	add_child(bf_test)
	wave_mgr.current_level = 2
	global_vars.current_difficulty = global_vars.difficulty.hard

	var warrior_res = load("res://resources/units/enemy_warrior.tres")
	var boss_res = load("res://resources/units/enemy_boss.tres")
	bf_test._on_unit_spawn_requested(warrior_res, GameManager.Team.ENEMY)
	bf_test._on_unit_spawn_requested(boss_res, GameManager.Team.ENEMY)

	var enemy_children = bf_test.enemy_units_container.get_children()
	assert(enemy_children.size() == 2, "Two enemies spawned")
	var warrior_node = enemy_children[0]
	var boss_node = enemy_children[1]

	var w_hp_before: int = warrior_node.health_component.current_health
	var b_hp_before: int = boss_node.health_component.current_health
	var w_armor: int = warrior_node.health_component.armor
	var b_armor: int = boss_node.health_component.armor

	# Level 2 Hard: Regular = 132 dmg, Boss = 126 dmg
	var expected_w_taken = maxi(1, 132 - w_armor)
	var expected_b_taken = maxi(1, 126 - b_armor)

	bf_test._on_meteor_triggered()

	var w_taken = w_hp_before - warrior_node.health_component.current_health
	var b_taken = b_hp_before - boss_node.health_component.current_health
	assert(w_taken == expected_w_taken, "Warrior damage taken mismatch: exp %d, got %d" % [expected_w_taken, w_taken])
	assert(b_taken == expected_b_taken, "Boss damage taken mismatch: exp %d, got %d" % [expected_b_taken, b_taken])
	assert(boss_node.health_component.current_health > 300, "Boss should not be one-shotted by meteor")

	bf_test.queue_free()

	# Test HUD dynamic cooldown behavior
	var hud_meteor_test = hud_scene.instantiate()
	add_child(hud_meteor_test)
	wave_mgr.current_level = 3
	global_vars.current_difficulty = global_vars.difficulty.impossible
	hud_meteor_test.update_meteor_cooldown_scale()
	assert(is_equal_approx(hud_meteor_test.max_meteor_cooldown, 32.0), "HUD Level 3 Impossible cooldown must be 32.0s")

	hud_meteor_test._on_meteor_pressed()
	assert(is_equal_approx(hud_meteor_test.meteor_cooldown, 32.0), "Meteor cooldown must start at max")
	assert(hud_meteor_test.meteor_button.disabled == true, "Meteor button disabled during cooldown")

	hud_meteor_test._process(12.0)
	assert(is_equal_approx(hud_meteor_test.meteor_cooldown, 20.0), "Meteor cooldown must advance")
	hud_meteor_test._process(20.0)
	assert(hud_meteor_test.meteor_cooldown == 0.0, "Meteor cooldown should reach 0")
	assert(hud_meteor_test.meteor_button.disabled == false, "Meteor button re-enabled")
	assert("[SPACE]" in hud_meteor_test.meteor_button.text, "Meteor button shows [SPACE]")

	hud_meteor_test.queue_free()
	print("[PASS] Test 10: Special Attack (Meteor) dynamic scaling & cooldown verified.")

	# Test 11: EconomyManager gold persistence, level reset & restart verification
	var eco_mgr = get_node_or_null("/root/EconomyManager")
	assert(eco_mgr != null, "EconomyManager must exist")
	assert(eco_mgr.has_method("reset_economy"), "EconomyManager must implement reset_economy()")
	assert(eco_mgr.has_method("reset_for_level"), "EconomyManager must implement reset_for_level()")

	# Initial gold verification
	eco_mgr.reset_economy()
	assert(eco_mgr.player_gold == 100, "EconomyManager.player_gold must start at 100")
	assert(eco_mgr.enemy_gold == 0, "EconomyManager.enemy_gold must start at 0")

	# Simulate gold accumulation during a battle
	eco_mgr.add_gold(GameManager.Team.PLAYER, 450)
	assert(eco_mgr.player_gold == 550, "Gold accumulation must work")

	# Reset on fresh start/restart
	eco_mgr.reset_economy()
	assert(eco_mgr.player_gold == 100, "reset_economy() must strictly restore player_gold to 100")

	# Custom starting gold support
	eco_mgr.reset_economy(250)
	assert(eco_mgr.player_gold == 250, "reset_economy(250) must set player_gold to 250")

	# Reset for level
	eco_mgr.reset_for_level(2)
	assert(eco_mgr.player_gold == 100, "reset_for_level(2) must restore player_gold to 100")

	# Verify WaveManager.start_level invokes EconomyManager reset
	eco_mgr.add_gold(GameManager.Team.PLAYER, 300)
	assert(eco_mgr.player_gold == 400, "Gold accumulation before level start")
	wave_mgr.start_level(2)
	assert(eco_mgr.player_gold == 100, "WaveManager.start_level must reset player_gold to 100")

	# Verify BattleField instantiation resets economy
	eco_mgr.add_gold(GameManager.Team.PLAYER, 200)
	assert(eco_mgr.player_gold == 300, "Gold accumulated")
	var bf_eco_test = battle_scene.instantiate()
	add_child(bf_eco_test)
	assert(eco_mgr.player_gold == 100, "BattleField ready must reset player_gold to 100")
	bf_eco_test.queue_free()

	# Verify unit purchase signals and affordability
	var gold_signal_events: Array = []
	var test_sub = func(team, new_amount, delta):
		gold_signal_events.append({"team": team, "amount": new_amount, "delta": delta})
	Events.gold_changed.connect(test_sub)

	assert(eco_mgr.can_afford(GameManager.Team.PLAYER, 25) == true, "Can afford 25g with 100g")
	assert(eco_mgr.can_afford(GameManager.Team.PLAYER, 120) == false, "Cannot afford 120g with 100g")
	var spend_success = eco_mgr.spend_gold(GameManager.Team.PLAYER, 25)
	assert(spend_success == true, "Spend 25g succeeds")
	assert(eco_mgr.player_gold == 75, "Player gold decreased to 75")
	assert(gold_signal_events.size() > 0, "gold_changed signal emitted on spend")
	assert(gold_signal_events[-1].amount == 75, "Latest signal matches player_gold")
	assert(gold_signal_events[-1].delta == -25, "Latest signal delta matches -25")

	# Reset back to default
	eco_mgr.reset_economy()
	Events.gold_changed.disconnect(test_sub)
	assert(eco_mgr.player_gold == 100, "Economy reset after signal test")
	print("[PASS] Test 11: EconomyManager gold persistence, level reset & restart verified.")

	print("--- All Tests Succeeded! Exiting with 0 ---")
	get_tree().quit(0)
