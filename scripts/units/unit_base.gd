extends CharacterBody2D
class_name UnitBase

@export var unit_data: Resource
var team: int = 0 # 0 = Player (moves right), 1 = Enemy (moves left)
var facing_direction: float = 1.0
var lane_index: int = 1 # 0 = Upper, 1 = Center, 2 = Lower
var depth_scale_mult: float = 1.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var combat_component: CombatComponent = $CombatComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_attack: AudioStreamPlayer2D = $SFX_Attack
@onready var sfx_die: AudioStreamPlayer2D = $SFX_Die

enum State { WALK, IDLE, ATTACK, DIE }
var current_state: State = State.WALK

var target_node: Node2D = null

# Animation frame management
var anim_timer: float = 0.0
var anim_frame: int = 0
var anim_fps: float = 8.0
var is_dying: bool = false

# Attack cadence
var attack_timer: float = 0.0
var has_dealt_damage: bool = false

var die_sounds = [
	preload("res://age of war sprites/audio/sfx/die_01.mp3"),
	preload("res://age of war sprites/audio/sfx/die_02.mp3"),
	preload("res://age of war sprites/audio/sfx/die_03.mp3"),
	preload("res://age of war sprites/audio/sfx/die_04.mp3"),
	preload("res://age of war sprites/audio/sfx/die_05.mp3")
]

var attack_sounds = [
	preload("res://age of war sprites/audio/sfx/sword_clash_01.mp3"),
	preload("res://age of war sprites/audio/sfx/sword_clash_02.mp3"),
	preload("res://age of war sprites/audio/sfx/stab_01.mp3"),
	preload("res://age of war sprites/audio/sfx/stab_02.mp3")
]

func _ready() -> void:
	if team == 0:
		facing_direction = 1.0
		sprite.flip_h = false
		collision_layer = 2 # Layer 2 = Player
		collision_mask = 0
	else:
		facing_direction = -1.0
		sprite.flip_h = true
		collision_layer = 4 # Layer 3 = Enemy
		collision_mask = 0
	
	if unit_data:
		_apply_unit_data()
	add_to_group("player_units" if team == GameManager.Team.PLAYER else "wave_enemy_units")
	
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	
	Events.unit_spawned.emit(self, team)
	_set_state(State.WALK)
	_update_depth_sort()

func _apply_unit_data() -> void:
	health_component.initialize(unit_data.max_health, unit_data.armor)
	combat_component.initialize(
		unit_data.attack_damage,
		unit_data.attack_range,
		unit_data.attack_cooldown,
		unit_data.is_ranged,
		unit_data.projectile_speed
	)
	
	if unit_data.texture_walk:
		sprite.texture = unit_data.texture_walk
		sprite.hframes = unit_data.walk_frames
		sprite.vframes = 1
		sprite.scale = unit_data.sprite_scale * depth_scale_mult
		sprite.position.y = unit_data.sprite_offset_y
	queue_redraw()

func _physics_process(delta: float) -> void:
	if current_state == State.DIE:
		_update_die_animation(delta)
		return
	
	_check_environment_and_targets()
	if current_state == State.WALK and _reached_opposing_base():
		_set_state(State.ATTACK)
	_update_animation(delta)
	
	match current_state:
		State.WALK:
			velocity.x = facing_direction * (unit_data.move_speed if unit_data else 60.0)
			move_and_slide()
			_update_depth_sort()
		State.IDLE:
			velocity = Vector2.ZERO
		State.ATTACK:
			velocity = Vector2.ZERO
			_handle_attack_logic(delta)

func _update_depth_sort() -> void:
	z_index = clampi(roundi(global_position.y), -4095, 4095)
	sprite.z_as_relative = false
	sprite.z_index = z_index + 1

func _get_opposing_base() -> BaseFortress:
	var scene = get_tree().current_scene
	if not scene:
		return null
	var base_path = "Bases/EnemyBase" if team == GameManager.Team.PLAYER else "Bases/PlayerBase"
	return scene.get_node_or_null(base_path) as BaseFortress

func _reached_opposing_base() -> bool:
	var opposing_base = _get_opposing_base()
	if not opposing_base:
		return false
	var base_center = opposing_base.global_position + opposing_base.hitbox_offset
	var half_size = opposing_base.hitbox_size * 0.5
	var forward_distance = (base_center.x - global_position.x) * facing_direction
	return forward_distance >= -half_size.x and forward_distance <= half_size.x + 12.0 and absf(base_center.y - global_position.y) <= half_size.y + 25.0

func _check_environment_and_targets() -> void:
	var range_dist = unit_data.attack_range if unit_data else 50.0
	var battle_scene = get_tree().current_scene
	
	# Search enemy in the same lane (or close vertical alignment)
	var nearest_enemy: Node2D = null
	var nearest_distance: float = INF
	var enemy_container_path = "Lane/EnemyUnits" if team == GameManager.Team.PLAYER else "Lane/PlayerUnits"
	var enemy_container = battle_scene.get_node_or_null(enemy_container_path) if battle_scene else null
	
	if enemy_container:
		for col in enemy_container.get_children():
			if not is_instance_valid(col) or not (col is UnitBase) or col.current_state == State.DIE:
				continue
			var horizontal_distance = absf(col.global_position.x - global_position.x)
			var vertical_distance = absf(col.global_position.y - global_position.y)
			
			# Melee units only clash in same lane (dy <= 12). Ranged units can shoot across lanes (dy <= 45).
			var max_allowed_dy = 45.0 if (unit_data and unit_data.is_ranged) else 14.0
			if horizontal_distance > range_dist + 20.0 or vertical_distance > max_allowed_dy:
				continue
			if horizontal_distance < nearest_distance:
				nearest_distance = horizontal_distance
				nearest_enemy = col

	var opposing_base = _get_opposing_base()
	if opposing_base:
		var base_center = opposing_base.global_position + opposing_base.hitbox_offset
		var base_half_size = opposing_base.hitbox_size * 0.5
		var base_forward_distance = (base_center.x - global_position.x) * facing_direction
		var base_vertical_distance = absf(base_center.y - global_position.y)
		var base_attack_reach = range_dist + base_half_size.x
		var base_in_attack_range = base_forward_distance >= -base_half_size.x and base_forward_distance <= base_attack_reach and base_vertical_distance <= base_half_size.y + 25.0
		if base_in_attack_range and (nearest_distance == INF or absf(base_forward_distance) <= nearest_distance):
			nearest_enemy = opposing_base

	if nearest_enemy:
		target_node = nearest_enemy
		if current_state != State.ATTACK:
			_set_state(State.ATTACK)
		sprite.flip_h = nearest_enemy.global_position.x < global_position.x
		return

	if current_state == State.ATTACK:
		target_node = null
		_set_state(State.WALK)

func _handle_attack_logic(delta: float) -> void:
	if not target_node or not is_instance_valid(target_node):
		_set_state(State.WALK)
		return
		
	if target_node is UnitBase and target_node.current_state == State.DIE:
		target_node = null
		_set_state(State.WALK)
		return
	
	attack_timer += delta
	var cooldown = unit_data.attack_cooldown if unit_data else 1.0
	
	if attack_timer >= cooldown:
		attack_timer = 0.0
		anim_frame = 0
		has_dealt_damage = false
		_play_attack_sound()
	
	# Deal damage midway through attack animation
	var total_atk_frames = unit_data.attack_frames if unit_data else 8
	var trigger_frame = total_atk_frames / 2
	if anim_frame >= trigger_frame and not has_dealt_damage:
		has_dealt_damage = true
		combat_component.perform_attack(self, target_node)

func _update_animation(delta: float) -> void:
	if not unit_data:
		return
		
	anim_timer += delta
	var frame_duration = 1.0 / anim_fps
	
	if anim_timer >= frame_duration:
		anim_timer = 0.0
		anim_frame += 1
		
		match current_state:
			State.WALK:
				if anim_frame >= unit_data.walk_frames:
					anim_frame = 0
				sprite.frame = anim_frame
			State.ATTACK:
				if anim_frame >= unit_data.attack_frames:
					anim_frame = unit_data.attack_frames - 1
				sprite.frame = anim_frame

func _update_die_animation(delta: float) -> void:
	if not unit_data or not unit_data.texture_death:
		queue_free()
		return
		
	anim_timer += delta
	var frame_duration = 1.0 / 10.0
	
	if anim_timer >= frame_duration:
		anim_timer = 0.0
		anim_frame += 1
		if anim_frame >= unit_data.death_frames:
			queue_free()
		else:
			sprite.frame = anim_frame

func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	anim_frame = 0
	anim_timer = 0.0
	
	if not unit_data:
		return
		
	match current_state:
		State.WALK:
			sprite.texture = unit_data.texture_walk
			sprite.hframes = unit_data.walk_frames
		State.ATTACK:
			sprite.texture = unit_data.texture_attack
			sprite.hframes = unit_data.attack_frames
			attack_timer = unit_data.attack_cooldown
			has_dealt_damage = false
		State.DIE:
			sprite.texture = unit_data.texture_death
			sprite.hframes = unit_data.death_frames
			_play_die_sound()

func _play_attack_sound() -> void:
	if attack_sounds.size() > 0:
		var snd = attack_sounds[randi() % attack_sounds.size()]
		sfx_attack.stream = snd
		sfx_attack.pitch_scale = randf_range(0.9, 1.1)
		sfx_attack.play()

func _play_die_sound() -> void:
	if die_sounds.size() > 0:
		var snd = die_sounds[randi() % die_sounds.size()]
		sfx_die.stream = snd
		sfx_die.pitch_scale = randf_range(0.85, 1.15)
		sfx_die.play()

func _on_health_changed(_cur: int, _max: int) -> void:
	# Subtle white flash feedback on hit
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2.5, 2.5, 2.5), 0.06)
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.08)
	queue_redraw()

func _on_died() -> void:
	_set_state(State.DIE)
	var bounty = unit_data.gold_bounty if unit_data else 10
	Events.unit_died.emit(self, team, bounty)
	
	# Credit gold to opposing team
	if team == GameManager.Team.ENEMY:
		EconomyManager.add_gold(GameManager.Team.PLAYER, bounty)
	else:
		EconomyManager.add_gold(GameManager.Team.ENEMY, bounty)

func _draw() -> void:
	if current_state == State.DIE or not health_component:
		return
	
	# Overhead Health Bar with depth scaling
	var bar_w = 36.0 * depth_scale_mult
	var bar_h = 4.0
	var bar_x = -bar_w / 2.0
	var bar_y = sprite.position.y - (38.0 * depth_scale_mult)
	
	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	var pct = float(health_component.current_health) / float(max(1, health_component.max_health))
	var bar_color = Color(0.2, 0.8, 0.3) if team == 0 else Color(0.9, 0.25, 0.25)
	draw_rect(Rect2(bar_x, bar_y, bar_w * pct, bar_h), bar_color)
