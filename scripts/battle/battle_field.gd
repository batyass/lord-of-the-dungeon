extends Node2D

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var player_units_container: Node2D = $Lane/PlayerUnits
@onready var enemy_units_container: Node2D = $Lane/EnemyUnits
@onready var camera: Camera2D = $Camera2D

var unit_base_scene: PackedScene

# Precise pixel-verified road coordinates
# Road surface spans Y=410 to Y=480 on all 3 maps (Center of road = 445)
# Lane 0 (Upper / Background): Y = 425, scale 0.90x, slightly darker
# Lane 1 (Middle / Center):     Y = 445, scale 1.00x, normal
# Lane 2 (Lower / Foreground): Y = 465, scale 1.10x, slightly brighter
const LEVEL_LANE_Y = {
	1: [425.0, 445.0, 465.0],
	2: [425.0, 445.0, 465.0],
	3: [425.0, 445.0, 465.0]
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

func _ready() -> void:
	unit_base_scene = load("res://scenes/units/unit_base.tscn")
	Events.unit_spawn_requested.connect(_on_unit_spawn_requested)
	Events.meteor_triggered.connect(_on_meteor_triggered)
	Events.level_changed.connect(_on_level_changed)
	
	_update_background(1)
	GameManager.start_battle()
	
	# Explicitly start Level 1 music immediately on battle start
	if has_node("/root/MusicManager"):
		MusicManager.play_level(1)

func _on_level_changed(level_num: int, _title: String) -> void:
	_update_background(level_num)
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

func _realign_active_units_for_level(level_num: int) -> void:
	var target_lanes = LEVEL_LANE_Y.get(level_num, [425.0, 445.0, 465.0])
	var all_units = player_units_container.get_children() + enemy_units_container.get_children()
	for unit in all_units:
		if is_instance_valid(unit) and unit is UnitBase and unit.current_state != UnitBase.State.DIE:
			var target_y = target_lanes[unit.lane_index]
			var tween = create_tween()
			tween.tween_property(unit, "global_position:y", target_y, 0.4)

func _on_unit_spawn_requested(unit_data_res: Resource, team: int) -> void:
	if not unit_base_scene or not unit_data_res:
		return
	
	var lane_idx = 1
	if team == GameManager.Team.PLAYER:
		lane_idx = _get_highest_threat_lane_for_player()
	else:
		lane_idx = _get_strategic_lane_for_enemy()
	
	var active_lanes = LEVEL_LANE_Y.get(current_level_idx, [425.0, 445.0, 465.0])
	var unit = unit_base_scene.instantiate()
	unit.unit_data = unit_data_res
	unit.team = team
	unit.lane_index = lane_idx
	unit.depth_scale_mult = LANE_SCALE_MULT[lane_idx]
	unit.modulate = LANE_MODULATE[lane_idx]
	
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

func _on_meteor_triggered() -> void:
	var enemies = enemy_units_container.get_children()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_node("HealthComponent"):
			enemy.get_node("HealthComponent").take_damage(200)
	
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2(randf_range(-14, 14), randf_range(-14, 14)), 0.06)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)
