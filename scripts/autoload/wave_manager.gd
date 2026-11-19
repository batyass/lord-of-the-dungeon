extends Node

var current_level: int = 1
var current_wave: int = 1
var is_wave_active: bool = false
var is_wave_transitioning: bool = false
var spawn_timer: float = 0.0
var wave_enemies_spawned: int = 0
var wave_spawn_cursor: int = 0
var wave_base_composition: Array = []
var wave_remaining_composition: Array = []
var max_enemies_for_wave: int = 8
var live_enemy_count: int = 0
var wave_clear_pending: bool = false
var phase_timer: float = 0.0
var ai_phase: int = 0
var _previous_pressure_difference: float = 0.0
var stage_generation: int = 0

const PHASE_DURATION := 32.0
const MAX_LIVE_ENEMIES := 9
const LEVEL_WAVES := {
	1: [[7, 2, 0], [8, 4, 0], [10, 5, 0]],
	2: [[8, 3, 0], [9, 6, 1], [11, 7, 1]],
	3: [[9, 4, 0], [10, 7, 1], [13, 8, 1]]
}
const SPAWN_INTERVALS := {1: [3.2, 2.8, 2.4], 2: [2.9, 2.5, 2.2], 3: [2.6, 2.2, 1.9]}
const DIFFICULTY := {
	0: {"health": 1.65, "damage": 1.57, "speed": 1.155, "interval": 0.5875, "count": 1.31, "income": 0.695, "bounty": 0.715, "reward": 0.715},
	1: {"health": 1.685, "damage": 1.63, "speed": 1.18, "interval": 0.565, "count": 1.35, "income": 0.65, "bounty": 0.70, "reward": 0.70},
	2: {"health": 1.68, "damage": 1.60, "speed": 1.18, "interval": 0.60, "count": 1.32, "income": 0.65, "bounty": 0.70, "reward": 0.70}
}

var enemy_warrior_data: Resource
var enemy_archer_data: Resource
var enemy_boss_data: Resource

var level_names = {
	1: "The Underworld",
	2: "The Surface",
	3: "The Celestial Realm"
}

var wave_subtitles = {
	1: "SCOUTS",
	2: "ELITE BATTALION",
	3: "THE ROYAL ARMY"
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
		start_level(current_level)

func start_level(lvl: int) -> void:
	stage_generation += 1
	is_wave_transitioning = false
	if has_node("/root/EconomyManager"):
		EconomyManager.reset_for_level()
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
	var lvl_name = level_names.get(current_level, "LEVEL " + str(current_level))
	Events.level_changed.emit(current_level, lvl_name)
	start_wave(1)

func start_wave(w: int) -> void:
	stage_generation += 1
	is_wave_transitioning = false
	current_wave = clamp(w, 1, 3)
	is_wave_active = true
	wave_enemies_spawned = 0
	wave_spawn_cursor = 0
	spawn_timer = 2.0 # First enemy appears after 2s
	live_enemy_count = _count_live_wave_enemies()
	wave_clear_pending = false
	phase_timer = 0.0
	ai_phase = current_wave - 1
	_previous_pressure_difference = 0.0
	
	max_enemies_for_wave = get_wave_enemy_count(current_level, current_wave)
	wave_base_composition = get_wave_composition(current_level, current_wave)
	wave_remaining_composition = wave_base_composition.duplicate()
	
	var lvl_name = level_names.get(current_level, "LEVEL " + str(current_level))
	var wave_sub = wave_subtitles.get(current_wave, "ASSAULT")
	var full_title = "LVL %d %s: WAVE %d/3: %s" % [current_level, lvl_name, current_wave, wave_sub]
	
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

func get_difficulty_value(key: String) -> float:
	var difficulty_index: int = clampi(int(GlobalVariables.current_difficulty), 0, 2)
	return float(DIFFICULTY[difficulty_index][key])

func get_wave_composition(level: int, wave: int) -> Array:
	var row: Array = LEVEL_WAVES[clampi(level, 1, 3)][clampi(wave, 1, 3) - 1]
	var count_mult := get_difficulty_value("count")
	var result: Array = []
	for base_count in row:
		result.append(maxi(1, roundi(base_count * count_mult)) if base_count > 0 else 0)
	return result

func get_wave_enemy_count(level: int, wave: int) -> int:
	var total := 0
	for count in get_wave_composition(level, wave):
		total += count
	return total

func get_enemy_stat_multiplier(stat: String, level: int = -1) -> float:
	var lvl := clampi(current_level if level <= 0 else level, 1, 3)
	var base_mult := get_difficulty_value(stat)
	if stat in ["health", "damage"]:
		var level_scaler: float = [1.0, 1.08, 1.220][lvl - 1]
		return base_mult * level_scaler
	return base_mult

func get_meteor_damage(is_boss: bool = false, level: int = -1, difficulty: int = -1) -> int:
	var lvl := clampi(current_level if level <= 0 else level, 1, 3)
	var diff := clampi(int(GlobalVariables.current_difficulty) if difficulty < 0 and GlobalVariables and "current_difficulty" in GlobalVariables else (0 if difficulty < 0 else difficulty), 0, 2)
	if is_boss:
		var base_boss := 80.0 + float(lvl) * 15.0
		var boss_diff_mult := 1.0 + float(diff) * 0.15
		return roundi(base_boss * boss_diff_mult)
	else:
		var base_regular := 60.0 + float(lvl) * 30.0
		var diff_mult := 1.0 + float(diff) * 0.10
		return roundi(base_regular * diff_mult)

func get_meteor_cooldown(level: int = -1, difficulty: int = -1) -> float:
	var lvl := clampi(current_level if level <= 0 else level, 1, 3)
	var diff := clampi(int(GlobalVariables.current_difficulty) if difficulty < 0 and GlobalVariables and "current_difficulty" in GlobalVariables else (0 if difficulty < 0 else difficulty), 0, 2)
	var base_cooldown: float = 20.0 + float(lvl) * 2.0
	var diff_add: float = float(diff) * 3.0
	return base_cooldown + diff_add

func get_wave_spawn_interval(level: int, wave: int) -> float:
	return float(SPAWN_INTERVALS[clampi(level, 1, 3)][clampi(wave, 1, 3) - 1]) * get_difficulty_value("interval")

func _get_spawn_interval() -> float:
	var base_interval := get_wave_spawn_interval(current_level, current_wave)
	var phase_factor: float = [1.1, 1.0, 0.9][ai_phase]
	var pressure_adjustment := clampf((_get_player_army_strength() - live_enemy_count * 1.5) * 0.035, -0.1, 0.1)
	return clampf(base_interval * phase_factor * (1.0 - pressure_adjustment) + randf_range(-0.25, 0.25), 1.6, 5.2)

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
	var composition := wave_remaining_composition
	if composition[2] > 0 and wave_enemies_spawned >= int(max_enemies_for_wave / 3.0) and enemy_boss_data:
		composition[2] -= 1
		return enemy_boss_data
	var non_boss_total: int = composition[0] + composition[1]
	if non_boss_total <= 0:
		return enemy_boss_data
	var original_non_boss_total: int = wave_base_composition[0] + wave_base_composition[1]
	var warrior_threshold: int = roundi(float(wave_spawn_cursor + 1) * float(wave_base_composition[0]) / float(original_non_boss_total))
	var previous_threshold: int = roundi(float(wave_spawn_cursor) * float(wave_base_composition[0]) / float(original_non_boss_total))
	var choose_warrior: bool = bool(warrior_threshold > previous_threshold) and bool(int(composition[0]) > 0)
	if choose_warrior:
		composition[0] -= 1
		wave_spawn_cursor += 1
		return enemy_warrior_data
	composition[1] -= 1
	wave_spawn_cursor += 1
	return enemy_archer_data

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

func get_wave_clear_reward(level: int, wave: int) -> int:
	var base_reward := 15 + wave * 12 + level * 5
	var mult: float = get_difficulty_value("reward")
	return maxi(5, roundi(float(base_reward) * mult))

func get_level_clear_reward(level: int) -> int:
	var base_reward := 50 + level * 15
	var mult: float = get_difficulty_value("reward")
	return maxi(15, roundi(float(base_reward) * mult))

func _advance_wave() -> void:
	is_wave_transitioning = true
	wave_clear_pending = false
	var cleared_level = current_level
	var cleared_wave = current_wave
	var transition_generation = stage_generation
	var next_wave = current_wave + 1
	var next_level = current_level + 1
	if current_wave < 3:
		EconomyManager.add_gold(GameManager.Team.PLAYER, get_wave_clear_reward(current_level, current_wave))
	elif current_level < 3:
		EconomyManager.add_gold(GameManager.Team.PLAYER, get_level_clear_reward(current_level))
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
