extends Node

# --- Economy Signals ---
signal gold_changed(team: int, new_amount: int, delta: int)

# --- Unit Lifecycle Signals ---
signal unit_spawn_requested(unit_data_res: Resource, team: int)
signal unit_spawned(unit: Node2D, team: int)
signal unit_died(unit: Node2D, team: int, gold_bounty: int)

# --- Combat Signals ---
signal damage_dealt(target: Node2D, amount: int)
signal base_damaged(team: int, current_hp: int, max_hp: int)
signal base_destroyed(losing_team: int)
signal meteor_triggered()

# --- Game Flow Signals ---
signal game_state_changed(old_state: int, new_state: int)
signal level_changed(level_number: int, level_title: String)
signal wave_started(wave_number: int, wave_title: String)
signal wave_completed(wave_number: int)
