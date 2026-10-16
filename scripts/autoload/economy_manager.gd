extends Node

var player_gold: int = 100
var enemy_gold: int = 0
var passive_income_rate: int = 3 # Starting gold per second
var income_accumulator: float = 0.0
var previous_income_rate: int = -1
var income_game_state: int = -1

func get_current_passive_income_rate() -> int:
	var level_bonus = maxi(0, WaveManager.current_level - 1)
	var wave_bonus = maxi(0, int((WaveManager.current_wave - 1) / 2))
	return passive_income_rate + level_bonus + wave_bonus

func _ready() -> void:
	Events.unit_died.connect(_on_unit_died)

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
