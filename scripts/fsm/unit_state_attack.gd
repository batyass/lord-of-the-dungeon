class_name UnitStateAttack
extends UnitState

var current_target: Node2D
var attack_cooldown_left: float = 0.0

func enter(msg: Dictionary = {}) -> void:
	if unit:
		unit.velocity = Vector2.ZERO
		if msg.has("target") and is_instance_valid(msg["target"]):
			current_target = msg["target"]
		else:
			current_target = unit.find_target()
		attack_cooldown_left = 0.0

func exit() -> void:
	current_target = null

func physics_update(delta: float) -> void:
	if not unit:
		return
	if unit.health_component and unit.health_component.is_dead:
		state_machine.transition_to("dead")
		return
	
	if not _is_target_valid(current_target):
		current_target = unit.find_target()
		if not _is_target_valid(current_target):
			state_machine.transition_to("move")
			return

	var dist = abs(current_target.global_position.x - unit.global_position.x)
	var max_range = unit.attack_range + 30.0
	if dist > max_range:
		state_machine.transition_to("move")
		return

	if attack_cooldown_left > 0.0:
		attack_cooldown_left -= delta
	else:
		_perform_attack()

func _perform_attack() -> void:
	if not unit or not _is_target_valid(current_target):
		return
	unit.play_animation("attack")
	if unit.combat_component:
		var spawn_pos = unit.get_projectile_spawn_position()
		var proj_container = unit.get_projectile_container()
		unit.combat_component.execute_attack(unit, current_target, proj_container, spawn_pos)
		attack_cooldown_left = unit.combat_component.get_attack_interval()
	else:
		attack_cooldown_left = 1.0

func _is_target_valid(t: Node2D) -> bool:
	if not is_instance_valid(t) or t.is_queued_for_deletion():
		return false
	var hp = t.get_node_or_null("HealthComponent")
	if hp and hp.is_dead:
		return false
	return true
