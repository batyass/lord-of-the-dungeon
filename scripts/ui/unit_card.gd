extends Button

@export var unit_data: Resource
@export var hotkey_text: String = "1"

var current_cooldown: float = 0.0
var max_cooldown: float = 1.0

@onready var cost_label: Label = $VBox/CostLabel
@onready var name_label: Label = $VBox/NameLabel
@onready var hotkey_label: Label = $HotkeyBadge/Label
@onready var cooldown_bar: ProgressBar = $CooldownBar

func _ready() -> void:
	pressed.connect(_on_pressed)
	Events.gold_changed.connect(_on_gold_changed)
	
	if unit_data:
		name_label.text = unit_data.display_name
		cost_label.text = str(unit_data.gold_cost) + "g"
		max_cooldown = unit_data.spawn_cooldown
	
	hotkey_label.text = "[" + hotkey_text + "]"
	cooldown_bar.visible = false

func _process(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta
		cooldown_bar.value = (current_cooldown / max_cooldown) * 100.0
		if current_cooldown <= 0:
			current_cooldown = 0
			cooldown_bar.visible = false
			_update_affordability()

func _on_pressed() -> void:
	if current_cooldown > 0 or not unit_data:
		return
	
	if EconomyManager.can_afford(GameManager.Team.PLAYER, unit_data.gold_cost):
		EconomyManager.spend_gold(GameManager.Team.PLAYER, unit_data.gold_cost)
		Events.unit_spawn_requested.emit(unit_data, GameManager.Team.PLAYER)
		current_cooldown = max_cooldown
		cooldown_bar.visible = true
		cooldown_bar.value = 100.0

func _on_gold_changed(_team: int, _new_amount: int, _delta: int) -> void:
	_update_affordability()

func _update_affordability() -> void:
	if not unit_data:
		return
	var can_buy = EconomyManager.can_afford(GameManager.Team.PLAYER, unit_data.gold_cost)
	if can_buy and current_cooldown <= 0:
		disabled = false
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		disabled = false # Keep clickable to show feedback or disable
		if current_cooldown > 0:
			modulate = Color(0.6, 0.6, 0.6, 0.8)
		elif not can_buy:
			modulate = Color(0.8, 0.4, 0.4, 0.9)
