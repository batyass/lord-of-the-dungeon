extends Node

var current_level: int = 1
var current_wave: int = 1
var is_wave_active: bool = false
var is_wave_transitioning: bool = false
var spawn_timer: float = 0.0
var wave_enemies_spawned: int = 0
var max_enemies_for_wave: int = 8
var live_enemy_count: int = 0
var wave_clear_pending: bool = false
var phase_timer: float = 0.0
var ai_phase: int = 0
var _previous_pressure_difference: float = 0.0
var stage_generation: int = 0

const PHASE_DURATION := 32.0
const MAX_LIVE_ENEMIES := 9

var enemy_warrior_data: Resource
var enemy_archer_data: Resource
var enemy_boss_data: Resource

var level_names = {
	1: "LES ENFERS",
	2: "LA TERRE",
	3: "LE ROYAUME CÉLESTE"
}

var wave_subtitles = {
	1: "ÉCLAIREURS",
	2: "BATAILLON D'ÉLITE",
	3: "L'ARMÉE DU ROI"
}

func _ready() -> void:
	enemy_warrior_data = load("res://resources/units/enemy_warrior.tres")
	enemy_archer_data = load("res://resources/units/enemy_archer.tres")
	enemy_boss_data = load("res://resources/units/enemy_boss.tres")
	Events.game_state_changed.connect(_on_game_state_changed)
	Events.unit_died.connect(_on_unit_died)
	start_level(1)

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	if new_state == GameManager.GameState.PLAYING:
		start_level(1)

func start_level(lvl: int) -> void:
	stage_generation += 1
	is_wave_transitioning = false
	if lvl == 1:
		for enemy in get_tree().get_nodes_in_group("wave_enemy_units"):
			if is_instance_valid(enemy):
				enemy.remove_from_group("wave_enemy_units")
				enemy.queue_free()
		live_enemy_count = 0
	current_level = clamp(lvl, 1, 3)
	current_wave = 1
	phase_timer = 0.0
	ai_phase = 0
	_previous_pressure_difference = 0.0
	var lvl_name = level_names.get(current_level, "NIVEAU " + str(current_level))
	Events.level_changed.emit(current_level, lvl_name)
	start_wave(1)

func start_wave(w: int) -> void:
	stage_generation += 1
	is_wave_transitioning = false
	current_wave = clamp(w, 1, 3)
	is_wave_active = true
	wave_enemies_spawned = 0
	spawn_timer = 2.0 # First enemy appears after 2s
	live_enemy_count = _count_live_wave_enemies()
	wave_clear_pending = false
	phase_timer = 0.0
	ai_phase = current_wave - 1
	_previous_pressure_difference = 0.0
	
	# Challenge rises with the campaign while the live-enemy cap limits pile-ups.
	max_enemies_for_wave = mini(32, 7 + (current_level - 1) * 4 + (current_wave - 1) * 3)
	
	var lvl_name = level_names.get(current_level, "NIVEAU " + str(current_level))
	var wave_sub = wave_subtitles.get(current_wave, "ASSAUT")
	var full_title = "NIV.%d %s — VAGUE %d/3 : %s" % [current_level, lvl_name, current_wave, wave_sub]
	
	Events.wave_started.emit(current_wave, full_title)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or not is_wave_active or is_wave_transitioning:
		return
	
	live_enemy_count = _count_live_wave_enemies()
	var pressure_difference = _get_player_army_strength() - live_enemy_count * 1.5
	if absf(pressure_difference - _previous_pressure_difference) >= 2.0:
		_previous_pressure_difference = pressure_difference
		if pressure_difference >= 6.0:
			ai_phase = 2
		elif pressure_difference >= 3.0:
			ai_phase = maxi(ai_phase, 1)
		elif pressure_difference <= -3.0:
			ai_phase = 0
	
	phase_timer += delta
	if phase_timer >= PHASE_DURATION:
		phase_timer = 0.0
		if ai_phase == 0:
			ai_phase = 1
		elif ai_phase == 1:
			ai_phase = 2
	
	if wave_clear_pending:
		live_enemy_count = _count_live_wave_enemies()
		if live_enemy_count <= 0 and wave_enemies_spawned >= max_enemies_for_wave:
			_advance_wave()
		return
	
	if wave_enemies_spawned >= max_enemies_for_wave or live_enemy_count >= MAX_LIVE_ENEMIES:
		return

	spawn_timer += delta
	var spawn_interval = _get_spawn_interval()
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_next_enemy()

func _get_spawn_interval() -> float:
	var base_interval = [4.8, 3.8, 3.0][ai_phase]
	var campaign_ramp = (current_level - 1) * 0.18 + (current_wave - 1) * 0.12
	var army_pressure = _get_player_army_strength()
	var pressure_adjustment = clampf((army_pressure - live_enemy_count * 1.5) * 0.035, -0.6, 0.35)
	var wave_speedup = (current_wave - 1) * 0.15
	return clampf(base_interval - campaign_ramp - pressure_adjustment - wave_speedup + randf_range(-0.45, 0.45), 1.8, 5.5)

func _get_player_army_strength() -> float:
	var count := 0
	for unit in get_tree().get_nodes_in_group("player_units"):
		if unit is UnitBase and is_instance_valid(unit) and unit.current_state != UnitBase.State.DIE:
			count += 1
	return float(count)

func _spawn_next_enemy() -> void:
	if wave_enemies_spawned >= max_enemies_for_wave or _count_live_wave_enemies() >= MAX_LIVE_ENEMIES:
		return
	var enemy_data = _choose_enemy_unit()
	if not enemy_data:
		return
	live_enemy_count = _count_live_wave_enemies() + 1
	wave_enemies_spawned += 1
	Events.unit_spawn_requested.emit(enemy_data, GameManager.Team.ENEMY)
	if wave_enemies_spawned >= max_enemies_for_wave:
		wave_clear_pending = true

func _choose_enemy_unit() -> Resource:
	var roll := randf()
	var heavy_phase_roll := randf()
	if ai_phase == 0:
		return enemy_warrior_data if enemy_warrior_data else enemy_archer_data
	if ai_phase == 1:
		if heavy_phase_roll < 0.015 + current_level * 0.01 and current_level >= 2 and enemy_boss_data:
			return enemy_boss_data
		return enemy_warrior_data if roll < 0.62 and enemy_warrior_data else enemy_archer_data
	if enemy_boss_data and current_level >= 2 and heavy_phase_roll < 0.04 + (current_level - 1) * 0.025:
		return enemy_boss_data
	if enemy_archer_data and roll < 0.42:
		return enemy_archer_data
	return enemy_warrior_data if enemy_warrior_data else enemy_archer_data

func _on_unit_died(unit: Node2D, team: int, _bounty: int) -> void:
	if team == GameManager.Team.ENEMY and unit.is_in_group("wave_enemy_units"):
		unit.remove_from_group("wave_enemy_units")
		live_enemy_count = _count_live_wave_enemies()
		if not is_wave_transitioning and live_enemy_count <= 0 and wave_enemies_spawned >= max_enemies_for_wave:
			wave_clear_pending = true
	if team == GameManager.Team.PLAYER and unit.is_in_group("player_units"):
		unit.remove_from_group("player_units")

func _count_live_wave_enemies() -> int:
	var count := 0
	for unit in get_tree().get_nodes_in_group("wave_enemy_units"):
		if unit is UnitBase and is_instance_valid(unit) and unit.current_state != UnitBase.State.DIE:
			count += 1
	return count

func _advance_wave() -> void:
	is_wave_transitioning = true
	wave_clear_pending = false
	var cleared_level = current_level
	var cleared_wave = current_wave
	var transition_generation = stage_generation
	var next_wave = current_wave + 1
	var next_level = current_level + 1
	if current_wave < 3:
		EconomyManager.add_gold(GameManager.Team.PLAYER, 15 + current_wave * 12 + current_level * 5)
	elif current_level < 3:
		EconomyManager.add_gold(GameManager.Team.PLAYER, 50 + current_level * 15)
	else:
		is_wave_active = false
		is_wave_transitioning = false
		GameManager.change_state(GameManager.GameState.VICTORY)
		return

	await get_tree().create_timer(1.5).timeout
	if stage_generation != transition_generation:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING or current_level != cleared_level:
		is_wave_transitioning = false
		return
	is_wave_transitioning = false
	if cleared_wave < 3:
		start_wave(next_wave)
	else:
		start_level(next_level)
