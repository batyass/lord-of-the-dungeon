extends Node2D

var current_age

enum phase {m, r, t}
var current_phase = phase.m
var first_phase_time = 60
var second_phase_time = 60

var enemy_units_container

signal change_age

var unit_timer

func _ready():
	self.global_position.y = 480
	
	unit_timer = get_node("unit_spawn_timer")
	
	current_age = "knight" # Invaders use Knight pack characters (Hero Knight, Huntress, King)
	unit_timer.start(2.5)
	enemy_units_container = get_node("/root/main_game/enemy_units")
	$change_age_timer.wait_time = 180
	$change_age_timer.start()
	$turret_timer.start()
	
	$phase_timer.wait_time = first_phase_time
	$phase_timer.start()

func spawn_melee():
	var unit = load("res://units/" + current_age + "/melee/" + current_age + "_melee.tscn").instantiate()
	unit.position = self.global_position
	unit.is_player_owned = false
	enemy_units_container.add_child(unit)
	var aura = get_node_or_null("EnemySpawnAura")
	if aura:
		aura.flash()

func spawn_range():
	var unit = load("res://units/" + current_age + "/range/" + current_age + "_range.tscn").instantiate()
	unit.position = self.global_position
	unit.is_player_owned = false
	enemy_units_container.add_child(unit)
	var aura = get_node_or_null("EnemySpawnAura")
	if aura:
		aura.flash()

func spawn_tank():
	var unit = load("res://units/" + current_age + "/tank/" + current_age + "_tank.tscn").instantiate()
	unit.position = self.global_position
	unit.is_player_owned = false
	enemy_units_container.add_child(unit)
	var aura = get_node_or_null("EnemySpawnAura")
	if aura:
		aura.flash()

func buy_turret():
	pass

func add_turret_spot():
	pass

func sell_turret():
	pass

func advance_to_next_age():
	pass

func _on_timer_timeout():
	if current_phase == phase.m:
		spawn_melee()
		unit_timer.wait_time = randf_range(2.0, 5.0)
	elif current_phase == phase.r:
		var roll = randf()
		if roll < 0.6:
			spawn_melee()
		else:
			spawn_range()
		unit_timer.wait_time = randf_range(2.5, 6.0)
	elif current_phase == phase.t:
		var roll = randf()
		if roll < 0.4:
			spawn_melee()
		elif roll < 0.75:
			spawn_range()
		else:
			spawn_tank()
		unit_timer.wait_time = randf_range(3.0, 7.0)

func _on_phase_timer_timeout():
	if current_phase == phase.m:
		current_phase = phase.r
		$phase_timer.wait_time = second_phase_time
		$phase_timer.start()
	elif current_phase == phase.r:
		current_phase = phase.t
