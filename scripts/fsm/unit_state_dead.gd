class_name UnitStateDead
extends UnitState

func enter(_msg: Dictionary = {}) -> void:
	if not unit:
		return
	unit.velocity = Vector2.ZERO
	unit.disable_combat_elements()
	unit.play_animation("dead")
	Events.unit_died.emit(unit, unit.team, unit.gold_bounty)
	var tween = unit.create_tween()
	tween.tween_property(unit, "modulate:a", 0.0, 0.8)
	tween.tween_callback(unit.queue_free)

func physics_update(_delta: float) -> void:
	pass
