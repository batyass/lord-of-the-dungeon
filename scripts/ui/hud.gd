extends CanvasLayer

@onready var player_hp_bar: ProgressBar = $Control/TopBar/PlayerHPContainer/ProgressBar
@onready var player_hp_label: Label = $Control/TopBar/PlayerHPContainer/ProgressBar/HPLabel
@onready var gold_label: Label = $Control/TopBar/GoldContainer/GoldLabel
@onready var wave_label: Label = $Control/TopBar/WaveContainer/WaveLabel

@onready var card_bat: Button = $Control/BottomBar/HBox/CardBat
@onready var card_skeleton: Button = $Control/BottomBar/HBox/CardSkeleton
@onready var card_golem: Button = $Control/BottomBar/HBox/CardGolem
@onready var meteor_button: Button = $Control/BottomBar/HBox/MeteorButton

var meteor_cooldown: float = 0.0
var max_meteor_cooldown: float = 25.0

func _ready() -> void:
	Events.gold_changed.connect(_on_gold_changed)
	Events.base_damaged.connect(_on_base_damaged)
	Events.wave_started.connect(_on_wave_started)
	meteor_button.pressed.connect(_on_meteor_pressed)
	
	_update_gold_display(EconomyManager.player_gold)
	player_hp_bar.max_value = 2500
	player_hp_bar.value = 2500
	player_hp_label.text = "2500 / 2500 HP"

func _process(delta: float) -> void:
	if meteor_cooldown > 0:
		meteor_cooldown -= delta
		if meteor_cooldown <= 0:
			meteor_cooldown = 0
			meteor_button.text = "MÉTÉORE\n[ESPACE]"
			meteor_button.disabled = false
		else:
			meteor_button.text = "MÉTÉORE\n%.1fs" % meteor_cooldown
			meteor_button.disabled = true
	
	# Keybinds
	if Input.is_action_just_pressed("summon_1") and card_bat:
		card_bat._on_pressed()
	elif Input.is_action_just_pressed("summon_2") and card_skeleton:
		card_skeleton._on_pressed()
	elif Input.is_action_just_pressed("summon_3") and card_golem:
		card_golem._on_pressed()
	elif Input.is_action_just_pressed("spell_meteor") and meteor_cooldown <= 0:
		_on_meteor_pressed()

func _on_meteor_pressed() -> void:
	if meteor_cooldown > 0:
		return
	meteor_cooldown = max_meteor_cooldown
	Events.meteor_triggered.emit()

func _on_gold_changed(team: int, new_amount: int, _delta: int) -> void:
	if team == GameManager.Team.PLAYER:
		_update_gold_display(new_amount)

func _update_gold_display(val: int) -> void:
	gold_label.text = "🪙 " + str(val) + "g (+%d/s)" % EconomyManager.get_current_passive_income_rate()

func _on_base_damaged(team: int, cur: int, max_val: int) -> void:
	if team == GameManager.Team.PLAYER:
		player_hp_bar.max_value = max_val
		player_hp_bar.value = cur
		player_hp_label.text = "%d / %d HP" % [cur, max_val]

func _on_wave_started(num: int, title: String) -> void:
	wave_label.text = title
	_update_gold_display(EconomyManager.player_gold)
