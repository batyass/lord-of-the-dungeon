extends Node

var passed: int = 0
var failed: int = 0

func check(cond: bool, msg: String) -> void:
	if not cond:
		failed += 1
		push_error("FAIL: " + msg)
		print("FAIL: " + msg)
	else:
		passed += 1
		print("PASS: " + msg)

func _ready() -> void:
	print("--- Gold Reset Verification Test ---")

	var econ_mgr = get_node_or_null("/root/EconomyManager")
	check(econ_mgr != null, "EconomyManager autoload exists")

	# Initial state
	econ_mgr.reset_economy()
	check(econ_mgr.player_gold == 100, "Initial player_gold == 100")

	# Simulate spending 300 gold
	econ_mgr.add_gold(GameManager.Team.PLAYER, 300)
	check(econ_mgr.player_gold == 400, "After +300, player_gold == 400")

	# Simulate level change -> reset_for_level
	econ_mgr.reset_for_level(2)
	check(econ_mgr.player_gold == 100, "After reset_for_level(2), player_gold == 100")

	# Simulate quit and relaunch -> reset_economy
	econ_mgr.reset_economy(100)
	check(econ_mgr.player_gold == 100, "After reset_economy(100), player_gold == 100")

	# Test with custom starting gold
	econ_mgr.reset_economy(250)
	check(econ_mgr.player_gold == 250, "After reset_economy(250), player_gold == 250")

	# Test gold not persisting between levels
	econ_mgr.reset_economy()
	econ_mgr.add_gold(GameManager.Team.PLAYER, 500)
	check(econ_mgr.player_gold == 600, "After earning 500, player_gold == 600")

	print("--- Gold Reset Tests: %d passed, %d failed ---" % [passed, failed])

	if failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
