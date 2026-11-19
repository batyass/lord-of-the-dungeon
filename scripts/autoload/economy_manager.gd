extends Node

const DEFAULT_STARTING_GOLD: int = 100
const DEFAULT_ENEMY_STARTING_GOLD: int = 0

var player_gold: int = DEFAULT_STARTING_GOLD
var enemy_gold: int = DEFAULT_ENEMY_STARTING_GOLD
var passive_income_rate: int = 3 # Starting gold per second
var income_accumulator: float = 0.0
var previous_income_rate: int = -1
var income_game_state: int = -1

func get_current_passive_income_rate() -> int:
	var mult: float = WaveManager.get_enemy_stat_multiplier("income")
	var level_bonus := maxi(0, WaveManager.current_level - 1)
	var wave_bonus := maxi(0, int((WaveManager.current_wave - 1) / 2))
	return maxi(1, roundi(float(passive_income_rate + level_bonus + wave_bonus) * mult))

func _ready() -> void:
	Events.unit_died.connect(_on_unit_died)
	reset_economy()

func reset_economy(starting_gold: int = DEFAULT_STARTING_GOLD) -> void:
	player_gold = starting_gold
	enemy_gold = DEFAULT_ENEMY_STARTING_GOLD
	income_accumulator = 0.0
	previous_income_rate = -1
	income_game_state = GameManager.current_state
	Events.gold_changed.emit(GameManager.Team.PLAYER, player_gold, 0)
	Events.gold_changed.emit(GameManager.Team.ENEMY, enemy_gold, 0)

func reset_for_level(starting_gold: int = DEFAULT_STARTING_GOLD) -> void:
	var resolved_gold: int = DEFAULT_STARTING_GOLD
	if starting_gold not in [1, 2, 3]:
		resolved_gold = starting_gold
	reset_economy(resolved_gold)

func _process(delta: float) -> void:
	var current_rate = get_current_passive_income_rate()
	if current_rate != previous_income_rate:
		previous_income_rate = current_rate
		Events.gold_changed.emit(GameManager.Team.PLAYER, player_gold, 0)
	if GameManager.current_state != income_game_state:
		income_game_state = GameManager.current_state
		income_accumulator = 0.0
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	income_accumulator += delta
	while income_accumulator >= 1.0:
		income_accumulator -= 1.0
		add_gold(GameManager.Team.PLAYER, current_rate)

func can_afford(team: int, amount: int) -> bool:
	if team == GameManager.Team.PLAYER:
		return player_gold >= amount
	return enemy_gold >= amount

func spend_gold(team: int, amount: int) -> bool:
	if not can_afford(team, amount):
		return false
	if team == GameManager.Team.PLAYER:
		player_gold -= amount
		Events.gold_changed.emit(team, player_gold, -amount)
	else:
		enemy_gold -= amount
		Events.gold_changed.emit(team, enemy_gold, -amount)
	return true

func add_gold(team: int, amount: int) -> void:
	if team == GameManager.Team.PLAYER:
		player_gold += amount
		GameManager.total_gold_earned += amount
		Events.gold_changed.emit(team, player_gold, amount)
	else:
		enemy_gold += amount
		Events.gold_changed.emit(team, enemy_gold, amount)

func _on_unit_died(_unit: Node2D, team: int, gold_bounty: int) -> void:
	if gold_bounty <= 0:
		return
	# When enemy dies, player receives bounty
	if team == GameManager.Team.ENEMY:
		add_gold(GameManager.Team.PLAYER, gold_bounty)
	else:
		add_gold(GameManager.Team.ENEMY, gold_bounty)
