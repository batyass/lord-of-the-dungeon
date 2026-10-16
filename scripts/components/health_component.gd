extends Node
class_name HealthComponent

signal health_changed(current: int, max_val: int)
signal died()

@export var max_health: int = 100
var current_health: int = 100
@export var armor: int = 0
var is_dead: bool = false

func initialize(max_hp: int, p_armor: int = 0) -> void:
	max_health = max_hp
	armor = p_armor
	current_health = max_hp
	is_dead = false
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> int:
	if is_dead:
		return 0
	var actual_damage = max(1, amount - armor)
	current_health = max(0, current_health - actual_damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		is_dead = true
		died.emit()
	return actual_damage

func heal(amount: int) -> void:
	if is_dead:
		return
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
