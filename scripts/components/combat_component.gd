extends Node
class_name CombatComponent

signal target_acquired(target: Node2D)
signal target_lost()
signal attacked()

@export var attack_damage: int = 20
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
@export var is_ranged: bool = false
@export var projectile_speed: float = 350.0

var can_attack: bool = true
var current_target: Node2D = null

func initialize(dmg: int, rng: float, cd: float, ranged: bool = false, proj_spd: float = 350.0) -> void:
	attack_damage = dmg
	attack_range = rng
	attack_cooldown = cd
	is_ranged = ranged
	projectile_speed = proj_spd

func perform_attack(attacker: Node2D, target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	attacked.emit()
	
	if is_ranged and target is UnitBase:
		var proj_scene = load("res://scenes/projectiles/projectile_base.tscn")
		if proj_scene:
			var proj = proj_scene.instantiate()
			var team = attacker.team if "team" in attacker else 0
			var start_pos = attacker.global_position + Vector2(0, -20)
			var target_pos = target.global_position + Vector2(0, -20)
			proj.launch(start_pos, target_pos, team, attack_damage, projectile_speed)
			if attacker.get_tree() and attacker.get_tree().current_scene:
				attacker.get_tree().current_scene.add_child(proj)
			elif attacker.get_parent():
				attacker.get_parent().add_child(proj)
		return
	if target.has_node("HealthComponent"):
		target.get_node("HealthComponent").take_damage(attack_damage)
	elif target.has_method("take_damage"):
		target.take_damage(attack_damage)
	elif "health_component" in target and target.health_component:
		target.health_component.take_damage(attack_damage)
