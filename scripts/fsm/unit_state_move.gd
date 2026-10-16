class_name UnitStateMove
extends UnitState

func enter(_msg: Dictionary = {}) -> void:
	if unit:
		unit.play_animation("move")

func physics_update(_delta: float) -> void:
	if not unit:
		return
	if unit.health_component and unit.health_component.is_dead:
		state_machine.transition_to("dead")
		return
	var target = unit.find_target()
	if target:
		state_machine.transition_to("attack", {"target": target})
		return
	unit.velocity.x = unit.move_direction * unit.move_speed
	unit.velocity.y = 0.0
	unit.move_and_slide()
