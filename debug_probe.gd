extends Node
# TEMPORARY DEBUG PROBE - delete after diagnosing the wave-3 stuck-mob bug.

var timer: float = 0.0
var elapsed: float = 0.0
const SNAPSHOT_INTERVAL := 2.0
const RUN_DURATION := 260.0

func _ready() -> void:
	Events.wave_started.connect(func(w, title): print("[EV] wave_started w=%d %s" % [w, title]))
	Events.level_changed.connect(func(l, title): print("[EV] level_changed l=%d %s" % [l, title]))
	Events.game_state_changed.connect(func(o, n): print("[EV] state %d -> %d" % [o, n]))
	Events.unit_spawn_requested.connect(_on_spawn)

func _on_spawn(res: Resource, team: int) -> void:
	print("[EV] spawn req team=%d id=%s" % [team, res.id])

func _process(delta: float) -> void:
	elapsed += delta
	timer += delta

	# Keep the player base alive so the match reaches the wave transitions.
	var bf = get_parent()
	var pbase = bf.get_node("Bases/PlayerBase")
	if pbase and pbase.has_node("HealthComponent"):
		pbase.get_node("HealthComponent").heal(9999)

	if elapsed >= RUN_DURATION:
		print("[EV] probe quitting after %.0fs" % elapsed)
		get_tree().quit()
		return

	if timer < SNAPSHOT_INTERVAL:
		return
	timer = 0.0

	var line := "T=%6.1f lvl=%d wave=%d spawned=%d/%d active=%s gstate=%d" % [
		elapsed, WaveManager.current_level, WaveManager.current_wave,
		WaveManager.wave_enemies_spawned, WaveManager.max_enemies_for_wave,
		str(WaveManager.is_wave_active), GameManager.current_state]

	var enemies = bf.get_node("Lane/EnemyUnits").get_children()
	var players = bf.get_node("Lane/PlayerUnits").get_children()
	line += " | nE=%d nP=%d" % [enemies.size(), players.size()]
	for u in enemies:
		if not is_instance_valid(u):
			continue
		line += " || E{x=%.0f st=%d tgt=%s}" % [
			u.global_position.x, u.current_state,
			("Y" if (u.target_node and is_instance_valid(u.target_node)) else "n")]
	for u in players:
		if not is_instance_valid(u):
			continue
		line += " || P{x=%.0f st=%d tgt=%s}" % [
			u.global_position.x, u.current_state,
			("Y" if (u.target_node and is_instance_valid(u.target_node)) else "n")]
	print(line)
