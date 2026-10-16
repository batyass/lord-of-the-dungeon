class_name UnitStateMachine
extends Node

@export var initial_state: UnitState
var current_state: UnitState
var states: Dictionary = {}

func init(unit_node: UnitBase) -> void:
	states.clear()
	for child in get_children():
		if child is UnitState:
			var key = child.name.to_lower().replace("state", "").replace("unit", "")
			states[key] = child
			states[child.name.to_lower()] = child
			child.unit = unit_node
			child.state_machine = self
	if initial_state:
		transition_to(initial_state.name.to_lower())
	elif has_node("MoveState"):
		transition_to("move")
	elif has_node("IdleState"):
		transition_to("idle")

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	var key: String = target_state_name.to_lower().replace("state", "").replace("unit", "")
	if not states.has(key):
		push_error("State '%s' does not exist in StateMachine on %s" % [target_state_name, get_parent().name])
		return
	if current_state:
		current_state.exit()
	current_state = states[key]
	current_state.enter(msg)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)
