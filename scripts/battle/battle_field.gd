extends Node2D

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var player_units_container: Node2D = $Lane/PlayerUnits
@onready var enemy_units_container: Node2D = $Lane/EnemyUnits
@onready var camera: Camera2D = $Camera2D
@onready var pause_menu: CanvasLayer = $PauseMenu

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if not get_tree().paused:
			pause_menu.open()

var unit_base_scene: PackedScene

# Per-level road calibration:
# Level 1 (The Underworld): Road spans Y=410 to Y=495 (center Y=452.0)
# Level 2 (The Surface):     Road spans Y=425 to Y=505 (center Y=465.0)
# Level 3 (Celestial Realm): Floating bridge spans Y=405 to Y=470 (center Y=438.0)
const LEVEL_LANE_Y = {
	1: [430.0, 452.0, 475.0],
	2: [445.0, 465.0, 485.0],
	3: [420.0, 438.0, 456.0]
}

const LEVEL_BASE_Y = {
	1: 452.0,
	2: 465.0,
	3: 438.0
}

const LANE_SCALE_MULT = [0.90, 1.00, 1.10]
const LANE_MODULATE = [Color(0.88, 0.88, 0.94), Color(1.0, 1.0, 1.0), Color(1.05, 1.05, 1.05)]

const PLAYER_SPAWN_X = 160.0
const ENEMY_SPAWN_X = 1120.0

var bg_textures = {
	1: preload("res://assets/backgrounds/level_1_hell_screen.png"),
	2: preload("res://assets/backgrounds/level_2_earth_screen.png"),
	3: preload("res://assets/backgrounds/level_3_sky_screen.png")
}

var current_level_idx: int = 1
var selected_player_lane: int = 1

func _ready() -> void:
	unit_base_scene = load("res://scenes/units/unit_base.tscn")
	Events.unit_spawn_requested.connect(_on_unit_spawn_requested)
	Events.meteor_triggered.connect(_on_meteor_triggered)
	Events.level_changed.connect(_on_level_changed)
	var hud = get_node_or_null("HUD")
	if hud and hud.has_signal("lane_changed"):
		hud.lane_changed.connect(_on_player_lane_changed)
		if hud.has_method("get_selected_lane"):
			_on_player_lane_changed(hud.get_selected_lane())
	
	var initial_level = 1
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr:
		initial_level = wave_mgr.current_level
	_update_background(initial_level)
	_realign_bases_for_level(initial_level)
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_for_level()
	GameManager.start_battle()
	
	if has_node("/root/MusicManager"):
		MusicManager.play_level(initial_level)

func _on_level_changed(level_num: int, _title: String) -> void:
	_update_background(level_num)
	_realign_bases_for_level(level_num)
	_realign_active_units_for_level(level_num)
	if has_node("/root/MusicManager"):
		MusicManager.play_level(level_num)

func _update_background(level_num: int) -> void:
	current_level_idx = clamp(level_num, 1, 3)
	var tex = bg_textures.get(current_level_idx)
	if tex and background_sprite:
		var tween = create_tween()
		tween.tween_property(background_sprite, "modulate:a", 0.4, 0.2)
		tween.tween_callback(func():
			background_sprite.texture = tex
		)
		tween.tween_property(background_sprite, "modulate:a", 1.0, 0.3)

func _realign_bases_for_level(level_num: int) -> void:
	var base_y = LEVEL_BASE_Y.get(level_num, 452.0)
	var player_base = get_node_or_null("Bases/PlayerBase")
	var enemy_base = get_node_or_null("Bases/EnemyBase")
	if player_base and is_instance_valid(player_base):
		player_base.global_position.y = base_y
	if enemy_base and is_instance_valid(enemy_base):
		enemy_base.global_position.y = base_y

func _realign_active_units_for_level(level_num: int) -> void:
	var target_lanes = LEVEL_LANE_Y.get(level_num, [430.0, 452.0, 475.0])
	var all_units = player_units_container.get_children() + enemy_units_container.get_children()
	for unit in all_units:
		if is_instance_valid(unit) and unit is UnitBase and unit.current_state != UnitBase.State.DIE:
			var target_y = target_lanes[unit.lane_index]
			var tween = create_tween()
			tween.tween_property(unit, "global_position:y", target_y, 0.4)

func _on_player_lane_changed(lane_idx: int) -> void:
	selected_player_lane = clampi(lane_idx, 0, 2)

func _on_unit_spawn_requested(unit_data_res: Resource, team: int) -> void:
	if not unit_base_scene or not unit_data_res:
		return
	
	var lane_idx = selected_player_lane if team == GameManager.Team.PLAYER else _get_strategic_lane_for_enemy()
	
	var active_lanes = LEVEL_LANE_Y.get(current_level_idx, [430.0, 452.0, 475.0])
	var unit = unit_base_scene.instantiate()
	unit.unit_data = unit_data_res
	unit.team = team
	unit.lane_index = lane_idx
	unit.depth_scale_mult = LANE_SCALE_MULT[lane_idx]
	unit.modulate = LANE_MODULATE[lane_idx]
	if team == GameManager.Team.ENEMY:
		unit.enemy_health_multiplier = WaveManager.get_enemy_stat_multiplier("health")
		unit.enemy_damage_multiplier = WaveManager.get_enemy_stat_multiplier("damage")
		unit.enemy_speed_multiplier = WaveManager.get_enemy_stat_multiplier("speed")
		unit.bounty_multiplier = WaveManager.get_enemy_stat_multiplier("bounty")
		unit.enemy_level_bounty_multiplier = [1.0, 1.05, 1.10][WaveManager.current_level - 1]
		var uid = str(unit_data_res.id).to_lower()
		if uid == "enemy_king" or "boss" in uid or "king" in uid:
			unit.add_to_group("boss_units")
	
	if team == GameManager.Team.PLAYER:
		unit.global_position = Vector2(PLAYER_SPAWN_X, active_lanes[lane_idx])
		player_units_container.add_child(unit)
	else:
		unit.global_position = Vector2(ENEMY_SPAWN_X, active_lanes[lane_idx])
		enemy_units_container.add_child(unit)

func _get_highest_threat_lane_for_player() -> int:
	var enemy_units = enemy_units_container.get_children()
	var closest_x = INF
	var threat_lane = -1
	
	for enemy in enemy_units:
		if is_instance_valid(enemy) and enemy is UnitBase and enemy.current_state != UnitBase.State.DIE:
			if enemy.global_position.x < closest_x:
				closest_x = enemy.global_position.x
				threat_lane = enemy.lane_index
	
	if threat_lane != -1:
		return threat_lane
		
	var lane_counts = [0, 0, 0]
	for u in player_units_container.get_children():
		if is_instance_valid(u) and u is UnitBase and u.current_state != UnitBase.State.DIE:
			lane_counts[u.lane_index] += 1
	return lane_counts.find(lane_counts.min())

func _get_strategic_lane_for_enemy() -> int:
	var player_units = player_units_container.get_children()
	var max_x = -INF
	var most_advanced_lane = -1
	
	for player_u in player_units:
		if is_instance_valid(player_u) and player_u is UnitBase and player_u.current_state != UnitBase.State.DIE:
			if player_u.global_position.x > max_x:
				max_x = player_u.global_position.x
				most_advanced_lane = player_u.lane_index
				
	if most_advanced_lane != -1 and randf() < 0.65:
		return most_advanced_lane
	
	return randi() % 3

func _is_boss_unit(unit: Node) -> bool:
	if not is_instance_valid(unit):
		return false
	if unit.is_in_group("boss_units") or unit.is_in_group("boss"):
		return true
	if unit is UnitBase and unit.unit_data:
		var uid = str(unit.unit_data.id).to_lower()
		if uid == "enemy_king" or "boss" in uid or "king" in uid:
			return true
	return false

func get_meteor_damage(is_boss: bool = false, level: int = -1, difficulty: int = -1) -> int:
	var wave_mgr = get_node_or_null("/root/WaveManager")
	if wave_mgr and wave_mgr.has_method("get_meteor_damage"):
		return wave_mgr.get_meteor_damage(is_boss, level, difficulty)
	var lvl := clampi(current_level_idx if level <= 0 else level, 1, 3)
	var diff := difficulty
	if diff < 0:
		diff = int(GlobalVariables.current_difficulty) if GlobalVariables and "current_difficulty" in GlobalVariables else 0
	diff = clampi(diff, 0, 2)
	if is_boss:
		var base_boss := 80.0 + float(lvl) * 15.0
		var boss_diff_mult := 1.0 + float(diff) * 0.15
		return roundi(base_boss * boss_diff_mult)
	else:
		var base_regular := 60.0 + float(lvl) * 30.0
		var diff_mult := 1.0 + float(diff) * 0.10
		return roundi(base_regular * diff_mult)

func _on_meteor_triggered() -> void:
	var enemies = enemy_units_container.get_children()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_node("HealthComponent"):
			var is_boss: bool = _is_boss_unit(enemy)
			var damage: int = get_meteor_damage(is_boss)
			enemy.get_node("HealthComponent").take_damage(damage)
	
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2(randf_range(-14, 14), randf_range(-14, 14)), 0.06)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)
