class_name UnitStateIdle
extends UnitState

func enter(_msg: Dictionary = {}) -> void:
	if unit:
		unit.velocity = Vector2.ZERO
		unit.play_animation("idle")

func physics_update(_delta: float) -> void:
	if not unit:
		return
	if unit.health_component and unit.health_component.is_dead:
		state_machine.transition_to("dead")
		return
	var target = unit.find_target()
	if target:
		state_machine.transition_to("attack", {"target": target})
	else:
		state_machine.transition_to("move")
