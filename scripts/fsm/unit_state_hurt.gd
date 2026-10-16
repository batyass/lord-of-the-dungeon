class_name UnitStateHurt
extends UnitState

var hurt_duration: float = 0.15
var timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	if unit:
		unit.velocity = Vector2.ZERO
		unit.play_animation("hurt")
		timer = hurt_duration

func physics_update(delta: float) -> void:
	if not unit:
		return
	if unit.health_component and unit.health_component.is_dead:
		state_machine.transition_to("dead")
		return
	timer -= delta
	if timer <= 0.0:
		var target = unit.find_target()
		if target:
			state_machine.transition_to("attack", {"target": target})
		else:
			state_machine.transition_to("move")
