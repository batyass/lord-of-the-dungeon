extends Node

enum GameState { MENU, PLAYING, PAUSED, VICTORY, DEFEAT }
enum Team { PLAYER = 0, ENEMY = 1 }

var current_state: GameState = GameState.PLAYING
var match_duration: float = 0.0
var total_gold_earned: int = 0
var total_minions_summoned: int = 0
var total_enemies_killed: int = 0

func _ready() -> void:
	Events.base_destroyed.connect(_on_base_destroyed)
	Events.unit_spawned.connect(_on_unit_spawned)
	Events.unit_died.connect(_on_unit_died)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		match_duration += delta

func start_battle() -> void:
	match_duration = 0.0
	total_gold_earned = 0
	total_minions_summoned = 0
	total_enemies_killed = 0
	change_state(GameState.PLAYING)
	Engine.time_scale = 1.0

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	var old_state = current_state
	current_state = new_state
	Events.game_state_changed.emit(old_state, new_state)

func _on_unit_spawned(_unit: Node2D, team: int) -> void:
	if team == Team.PLAYER:
		total_minions_summoned += 1

func _on_unit_died(_unit: Node2D, team: int, _bounty: int) -> void:
	if team == Team.ENEMY:
		total_enemies_killed += 1

func _on_base_destroyed(losing_team: int) -> void:
	if losing_team == Team.ENEMY:
		change_state(GameState.VICTORY)
	else:
		change_state(GameState.DEFEAT)
