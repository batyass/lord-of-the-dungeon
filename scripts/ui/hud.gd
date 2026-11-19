extends CanvasLayer

signal lane_changed(lane_index: int)

@onready var player_hp_bar: ProgressBar = find_child("ProgressBar", true, false)
@onready var player_hp_label: Label = find_child("HPLabel", true, false)
@onready var enemy_hp_bar: ProgressBar = find_child("EnemyProgressBar", true, false)
@onready var enemy_hp_label: Label = find_child("EnemyHPLabel", true, false)
@onready var gold_label: Label = find_child("GoldLabel", true, false)
@onready var wave_label: Label = find_child("WaveLabel", true, false)
@onready var level_label: Label = find_child("LevelLabel", true, false)
@onready var level_tag: Label = find_child("LevelTag", true, false)
@onready var wave_tag: Label = find_child("WaveTag", true, false)
@onready var difficulty_container: Control = find_child("DifficultyContainer", true, false)
@onready var difficulty_label: Label = find_child("DifficultyLabel", true, false)
@onready var difficulty_tag: Label = find_child("DifficultyTag", true, false)

@onready var wave_banner: Control = find_child("WaveBanner", true, false)
@onready var wave_banner_panel: PanelContainer = find_child("WaveBannerPanel", true, false)
@onready var wave_banner_level_tag: Label = find_child("WaveBannerLevelTag", true, false)
@onready var wave_banner_diff_badge: Label = find_child("WaveBannerDiffBadge", true, false)
@onready var wave_banner_title: Label = find_child("WaveBannerTitle", true, false)
@onready var wave_banner_subtitle: Label = find_child("WaveBannerSubtitle", true, false)
@onready var wave_banner_pips: Label = find_child("WaveBannerPips", true, false)

@onready var level_transition: Control = find_child("LevelTransition", true, false)
@onready var level_trans_panel: PanelContainer = find_child("LevelTransPanel", true, false)
@onready var level_trans_title: Label = find_child("LevelTransTitle", true, false)
@onready var level_trans_subtitle: Label = find_child("LevelTransSubtitle", true, false)
@onready var level_trans_diff_badge: Label = find_child("LevelTransDiffBadge", true, false)

@onready var card_bat: Button = find_child("CardBat", true, false)
@onready var card_skeleton: Button = find_child("CardSkeleton", true, false)
@onready var card_golem: Button = find_child("CardGolem", true, false)
@onready var meteor_button: Button = find_child("MeteorButton", true, false)

@onready var lane_selector: Control = find_child("LaneSelector", true, false)
@onready var btn_lane_top: Button = find_child("BtnLaneTop", true, false)
@onready var btn_lane_mid: Button = find_child("BtnLaneMid", true, false)
@onready var btn_lane_bot: Button = find_child("BtnLaneBot", true, false)
@onready var active_lane_badge: Label = find_child("ActiveLaneBadge", true, false)

var meteor_cooldown: float = 0.0
var max_meteor_cooldown: float = 25.0

# Lane index: 0 = Top, 1 = Mid (default), 2 = Bot
var current_lane: int = 1
var selected_lane: int:
	get:
		return current_lane
	set(val):
		select_lane(val)

const COLOR_BASE_DARK := Color(0.043, 0.055, 0.078, 1.0)
const COLOR_GOLD := Color(1.0, 0.78, 0.22, 1.0)
const COLOR_TEXT_MUTED := Color(0.65, 0.72, 0.8, 0.75)
const COLOR_TEXT_ACTIVE := Color(1.0, 1.0, 1.0, 1.0)

const LEVEL_THEMES := {
	1: {
		"name": "The Underworld",
		"subtitle": "Abyssal Depths • Infernal Swarm",
		"tag": "LEVEL 1",
		"color": Color(1.0, 0.42, 0.28, 1.0),
		"accent": Color(1.0, 0.68, 0.35, 1.0),
		"border": Color(0.95, 0.35, 0.2, 0.8)
	},
	2: {
		"name": "The Surface",
		"subtitle": "Mortal Realm • Ranged Threats Emerge",
		"tag": "LEVEL 2",
		"color": Color(0.35, 0.88, 0.52, 1.0),
		"accent": Color(0.92, 0.78, 0.36, 1.0),
		"border": Color(0.35, 0.88, 0.52, 0.8)
	},
	3: {
		"name": "The Celestial Realm",
		"subtitle": "Celestial Sanctum • Imperial Royal Guard",
		"tag": "LEVEL 3",
		"color": Color(0.42, 0.72, 1.0, 1.0),
		"accent": Color(1.0, 0.86, 0.42, 1.0),
		"border": Color(0.42, 0.72, 1.0, 0.8)
	}
}

const DIFFICULTY_THEMES := {
	0: { # Normal
		"name": "NORMAL",
		"multiplier": "×1.0",
		"color": Color(0.32, 0.84, 0.52, 1.0),
		"border": Color(0.32, 0.84, 0.52, 0.75),
		"desc": "Standard Balance"
	},
	1: { # Hard
		"name": "HARD",
		"multiplier": "×1.25",
		"color": Color(1.0, 0.65, 0.18, 1.0),
		"border": Color(1.0, 0.65, 0.18, 0.8),
		"desc": "+25% HP • +15% DMG • +8% SPD"
	},
	2: { # Impossible
		"name": "IMPOSSIBLE",
		"multiplier": "×1.50",
		"color": Color(0.98, 0.26, 0.34, 1.0),
		"border": Color(0.98, 0.26, 0.34, 0.9),
		"desc": "+50% HP • +30% DMG • +15% SPD"
	}
}

const WAVE_PIPS := {
	1: "● ○ ○",
	2: "● ● ○",
	3: "● ● ●"
}

const WAVE_DESCRIPTORS := {
	1: "SCOUTS • RECONNAISSANCE ASSAULT",
	2: "ELITE BATTALION • ARMORED OFFENSIVE",
	3: "THE ROYAL ARMY • FINAL SIEGE"
}

var _wave_banner_tween: Tween
var _level_trans_tween: Tween
var _gold_pulse_tween: Tween

func _ready() -> void:
	Events.gold_changed.connect(_on_gold_changed)
	Events.base_damaged.connect(_on_base_damaged)
	Events.level_changed.connect(_on_level_changed)
	Events.wave_started.connect(_on_wave_started)
	if meteor_button:
		meteor_button.pressed.connect(_on_meteor_pressed)

	if btn_lane_top:
		btn_lane_top.pressed.connect(func(): select_lane(0))
	if btn_lane_mid:
		btn_lane_mid.pressed.connect(func(): select_lane(1))
	if btn_lane_bot:
		btn_lane_bot.pressed.connect(func(): select_lane(2))

	select_lane(1)

	_initialize_status_displays()
	update_meteor_cooldown_scale()
	_update_gold_display(EconomyManager.player_gold)

	_initialize_base_health(player_hp_bar, player_hp_label)
	_initialize_base_health(enemy_hp_bar, enemy_hp_label)

func _initialize_base_health(health_bar: ProgressBar, health_label: Label) -> void:
	if health_bar:
		health_bar.max_value = 2500
		health_bar.value = 2500
	if health_label:
		health_label.text = "2500 / 2500 HP"

func _process(delta: float) -> void:
	if meteor_cooldown > 0 and meteor_button:
		meteor_cooldown -= delta
		if meteor_cooldown <= 0:
			meteor_cooldown = 0
			meteor_button.text = "METEOR\n[SPACE]"
			meteor_button.disabled = false
		else:
			meteor_button.text = "METEOR\n%.1fs" % meteor_cooldown
			meteor_button.disabled = true

	# Keybinds for summoning and spells
	if Input.is_action_just_pressed("summon_1") and card_bat:
		card_bat._on_pressed()
	elif Input.is_action_just_pressed("summon_2") and card_skeleton:
		card_skeleton._on_pressed()
	elif Input.is_action_just_pressed("summon_3") and card_golem:
		card_golem._on_pressed()
	elif Input.is_action_just_pressed("spell_meteor") and meteor_cooldown <= 0:
		_on_meteor_pressed()

	# Keyboard shortcuts for lane selection (action-based)
	if Input.is_action_just_pressed("lane_top"):
		select_lane(0)
	elif Input.is_action_just_pressed("lane_mid"):
		select_lane(1)
	elif Input.is_action_just_pressed("lane_bot"):
		select_lane(2)
	elif Input.is_action_just_pressed("lane_up"):
		select_lane(max(0, current_lane - 1))
	elif Input.is_action_just_pressed("lane_down"):
		select_lane(min(2, current_lane + 1))

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	var code := key_event.keycode
	if code == KEY_NONE:
		code = key_event.physical_keycode

	var phys := key_event.physical_keycode

	if code == KEY_Q or phys == KEY_Q:
		select_lane(0)
		get_viewport().set_input_as_handled()
	elif code == KEY_W or phys == KEY_W:
		select_lane(1)
		get_viewport().set_input_as_handled()
	elif code == KEY_E or phys == KEY_E:
		select_lane(2)
		get_viewport().set_input_as_handled()
	elif code == KEY_UP or phys == KEY_UP:
		select_lane(max(0, current_lane - 1))
		get_viewport().set_input_as_handled()
	elif code == KEY_DOWN or phys == KEY_DOWN:
		select_lane(min(2, current_lane + 1))
		get_viewport().set_input_as_handled()

func select_lane(lane_idx: int) -> void:
	lane_idx = clampi(lane_idx, 0, 2)
	current_lane = lane_idx
	_update_lane_ui()
	lane_changed.emit(current_lane)
	if Events.has_signal("lane_changed"):
		Events.lane_changed.emit(current_lane)

func get_selected_lane() -> int:
	return current_lane

func get_current_lane() -> int:
	return current_lane

func _update_lane_ui() -> void:
	if btn_lane_top:
		btn_lane_top.button_pressed = (current_lane == 0)
		_apply_button_lane_style(btn_lane_top, current_lane == 0)
	if btn_lane_mid:
		btn_lane_mid.button_pressed = (current_lane == 1)
		_apply_button_lane_style(btn_lane_mid, current_lane == 1)
	if btn_lane_bot:
		btn_lane_bot.button_pressed = (current_lane == 2)
		_apply_button_lane_style(btn_lane_bot, current_lane == 2)

	if active_lane_badge:
		match current_lane:
			0:
				active_lane_badge.text = "ACTIVE: TOP [Q]"
				active_lane_badge.add_theme_color_override("font_color", COLOR_GOLD)
			1:
				active_lane_badge.text = "ACTIVE: MID [W]"
				active_lane_badge.add_theme_color_override("font_color", COLOR_GOLD)
			2:
				active_lane_badge.text = "ACTIVE: BOT [E]"
				active_lane_badge.add_theme_color_override("font_color", COLOR_GOLD)

func _apply_button_lane_style(btn: Button, is_active: bool) -> void:
	if not btn:
		return
	if is_active:
		btn.add_theme_color_override("font_color", COLOR_TEXT_ACTIVE)
		btn.add_theme_color_override("font_pressed_color", COLOR_TEXT_ACTIVE)
		btn.add_theme_color_override("font_hover_color", COLOR_TEXT_ACTIVE)
	else:
		btn.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
		btn.add_theme_color_override("font_hover_color", Color(0.9, 0.95, 1.0, 1.0))

func get_meteor_cooldown_for_state(level: int = -1, difficulty: int = -1) -> float:
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr and wave_mgr.has_method("get_meteor_cooldown"):
		return wave_mgr.get_meteor_cooldown(level, difficulty)
	var lvl := level
	if lvl <= 0:
		lvl = wave_mgr.current_level if wave_mgr else 1
	lvl = clampi(lvl, 1, 3)
	var diff := difficulty
	if diff < 0:
		if GlobalVariables and "current_difficulty" in GlobalVariables and GlobalVariables.current_difficulty != null:
			diff = int(GlobalVariables.current_difficulty)
		else:
			diff = 0
	diff = clampi(diff, 0, 2)
	var base_cooldown: float = 20.0 + float(lvl) * 2.0
	var diff_add: float = float(diff) * 3.0
	return base_cooldown + diff_add

func update_meteor_cooldown_scale(level: int = -1, difficulty: int = -1) -> void:
	max_meteor_cooldown = get_meteor_cooldown_for_state(level, difficulty)
	if meteor_cooldown > max_meteor_cooldown:
		meteor_cooldown = max_meteor_cooldown

func _on_meteor_pressed() -> void:
	if meteor_cooldown > 0:
		return
	update_meteor_cooldown_scale()
	meteor_cooldown = max_meteor_cooldown
	if meteor_button:
		meteor_button.disabled = true
		meteor_button.text = "METEOR\n%.1fs" % meteor_cooldown
	Events.meteor_triggered.emit()

func _on_gold_changed(team: int, new_amount: int, delta: int) -> void:
	if team == GameManager.Team.PLAYER:
		_update_gold_display(new_amount)
		if delta > 0:
			_pulse_gold_label()

func _pulse_gold_label() -> void:
	if not gold_label:
		return
	if _gold_pulse_tween and _gold_pulse_tween.is_valid():
		_gold_pulse_tween.kill()
	gold_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6, 1.0))
	_gold_pulse_tween = create_tween()
	_gold_pulse_tween.tween_property(gold_label, "theme_override_colors/font_color", Color(1.0, 0.85, 0.2, 1.0), 0.25)

func _update_gold_display(val: int) -> void:
	if gold_label:
		gold_label.text = "🪙 " + str(val) + "g (+%d/s)" % EconomyManager.get_current_passive_income_rate()

func _on_base_damaged(team: int, cur: int, max_val: int) -> void:
	if team == GameManager.Team.PLAYER:
		if player_hp_bar:
			player_hp_bar.max_value = max_val
			player_hp_bar.value = cur
		if player_hp_label:
			player_hp_label.text = "%d / %d HP" % [cur, max_val]
	elif team == GameManager.Team.ENEMY:
		if enemy_hp_bar:
			enemy_hp_bar.max_value = max_val
			enemy_hp_bar.value = cur
		if enemy_hp_label:
			enemy_hp_label.text = "%d / %d HP" % [cur, max_val]

func _initialize_status_displays() -> void:
	var current_lvl: int = 1
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr:
		current_lvl = wave_mgr.current_level
	var lvl_title: String = _get_level_name(current_lvl)
	_update_level_display(current_lvl, lvl_title)
	_update_difficulty_display()
	var current_w: int = 1
	if wave_mgr:
		current_w = wave_mgr.current_wave
	_update_wave_display(current_w, "WAVE %d: %s" % [current_w, _get_wave_name(current_w)])

func _get_level_name(lvl: int) -> String:
	var theme = LEVEL_THEMES.get(clampi(lvl, 1, 3))
	return theme["name"] if theme else "Level %d" % lvl

func _get_wave_name(w: int) -> String:
	match w:
		1: return "SCOUTS"
		2: return "ELITE BATTALION"
		3: return "THE ROYAL ARMY"
		_: return "ASSAULT"

func _update_level_display(lvl: int, lvl_title: String) -> void:
	var theme = LEVEL_THEMES.get(clampi(lvl, 1, 3), LEVEL_THEMES[1])
	if level_tag:
		level_tag.text = theme.get("tag", "LEVEL %d" % lvl)
	if level_label:
		level_label.text = lvl_title if lvl_title != "" else theme["name"]
		level_label.add_theme_color_override("font_color", theme["color"])

func _update_difficulty_display() -> void:
	var diff_idx: int = 0
	if GlobalVariables and "current_difficulty" in GlobalVariables and GlobalVariables.current_difficulty != null:
		diff_idx = clampi(int(GlobalVariables.current_difficulty), 0, 2)
	var theme = DIFFICULTY_THEMES.get(diff_idx, DIFFICULTY_THEMES[0])
	if difficulty_label:
		difficulty_label.text = theme["name"]
		difficulty_label.add_theme_color_override("font_color", theme["color"])
	update_meteor_cooldown_scale(-1, diff_idx)

func _update_wave_display(wave_num: int, title: String) -> void:
	var w: int = clampi(wave_num, 1, 3)
	if wave_tag:
		wave_tag.text = "WAVE %d / 3  %s" % [w, WAVE_PIPS.get(w, "● ○ ○")]
	if wave_label:
		wave_label.text = title

func show_wave_intro_banner(wave_num: int, _wave_title: String) -> void:
	if not wave_banner:
		return
	var w: int = clampi(wave_num, 1, 3)
	var current_lvl: int = 1
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr:
		current_lvl = wave_mgr.current_level
	var lvl_theme = LEVEL_THEMES.get(clampi(current_lvl, 1, 3), LEVEL_THEMES[1])
	var diff_idx: int = 0
	if GlobalVariables and "current_difficulty" in GlobalVariables and GlobalVariables.current_difficulty != null:
		diff_idx = clampi(int(GlobalVariables.current_difficulty), 0, 2)
	var diff_theme = DIFFICULTY_THEMES.get(diff_idx, DIFFICULTY_THEMES[0])

	if wave_banner_level_tag:
		wave_banner_level_tag.text = lvl_theme["name"].to_upper()
		wave_banner_level_tag.add_theme_color_override("font_color", lvl_theme["color"])
	if wave_banner_diff_badge:
		wave_banner_diff_badge.text = "DIFFICULTY: %s (%s)" % [diff_theme["name"], diff_theme["multiplier"]]
		wave_banner_diff_badge.add_theme_color_override("font_color", diff_theme["color"])
	if wave_banner_title:
		wave_banner_title.text = "WAVE %d / 3" % w
	if wave_banner_subtitle:
		wave_banner_subtitle.text = WAVE_DESCRIPTORS.get(w, "ENEMY ADVANCE")
	if wave_banner_pips:
		wave_banner_pips.text = WAVE_PIPS.get(w, "● ○ ○")

	if _wave_banner_tween and _wave_banner_tween.is_valid():
		_wave_banner_tween.kill()

	wave_banner.visible = true
	wave_banner.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var target_y: float = 58.0
	wave_banner.position.y = target_y - 12.0
	wave_banner.scale = Vector2(0.94, 0.94)
	wave_banner.pivot_offset = Vector2(wave_banner.size.x * 0.5, wave_banner.size.y * 0.5)

	_wave_banner_tween = create_tween()
	var delay: float = 0.5 if (level_transition and level_transition.visible and level_transition.modulate.a > 0.2) else 0.0
	if delay > 0.0:
		_wave_banner_tween.tween_interval(delay)

	_wave_banner_tween.parallel().tween_property(wave_banner, "modulate:a", 1.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_wave_banner_tween.parallel().tween_property(wave_banner, "position:y", target_y, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_wave_banner_tween.parallel().tween_property(wave_banner, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_wave_banner_tween.tween_interval(2.2)
	_wave_banner_tween.tween_property(wave_banner, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_wave_banner_tween.parallel().tween_property(wave_banner, "position:y", target_y - 8.0, 0.35)
	_wave_banner_tween.tween_callback(func():
		wave_banner.visible = false
	)

func show_level_transition_banner(lvl: int, lvl_title: String) -> void:
	if not level_transition:
		return
	var l: int = clampi(lvl, 1, 3)
	var lvl_theme = LEVEL_THEMES.get(l, LEVEL_THEMES[1])
	var diff_idx: int = 0
	if GlobalVariables and "current_difficulty" in GlobalVariables and GlobalVariables.current_difficulty != null:
		diff_idx = clampi(int(GlobalVariables.current_difficulty), 0, 2)
	var diff_theme = DIFFICULTY_THEMES.get(diff_idx, DIFFICULTY_THEMES[0])

	if level_trans_title:
		var display_title: String = lvl_title if lvl_title != "" else lvl_theme["name"]
		level_trans_title.text = "LEVEL %d: %s" % [l, display_title.to_upper()]
		level_trans_title.add_theme_color_override("font_color", lvl_theme["color"])
	if level_trans_subtitle:
		level_trans_subtitle.text = lvl_theme["subtitle"]
	if level_trans_diff_badge:
		level_trans_diff_badge.text = "%s (%s) — %s" % [diff_theme["name"], diff_theme["multiplier"], diff_theme["desc"]]
		level_trans_diff_badge.add_theme_color_override("font_color", diff_theme["color"])

	if _level_trans_tween and _level_trans_tween.is_valid():
		_level_trans_tween.kill()

	level_transition.visible = true
	level_transition.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if level_trans_panel:
		level_trans_panel.scale = Vector2(1.06, 1.06)
		level_trans_panel.pivot_offset = Vector2(level_trans_panel.size.x * 0.5, level_trans_panel.size.y * 0.5)

	_level_trans_tween = create_tween()
	_level_trans_tween.parallel().tween_property(level_transition, "modulate:a", 1.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if level_trans_panel:
		_level_trans_tween.parallel().tween_property(level_trans_panel, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_level_trans_tween.tween_interval(2.4)
	_level_trans_tween.tween_property(level_transition, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_level_trans_tween.tween_callback(func():
		level_transition.visible = false
	)

func _on_level_changed(lvl: int, lvl_title: String) -> void:
	update_meteor_cooldown_scale(lvl)
	_update_level_display(lvl, lvl_title)
	show_level_transition_banner(lvl, lvl_title)

func _on_wave_started(num: int, title: String) -> void:
	_update_wave_display(num, title)
	_update_gold_display(EconomyManager.player_gold)
	show_wave_intro_banner(num, title)
