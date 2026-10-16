@tool
extends Area2D
class_name BaseFortress

@export var team: int = 0
@export var max_health: int = 2500
@export var base_title: String = "Donjon des Enfers"
@export_group("Hitbox")
@export var hitbox_size: Vector2 = Vector2(80.0, 140.0):
	set(value):
		hitbox_size = Vector2(maxf(1.0, value.x), maxf(1.0, value.y))
		_update_hitbox()
		if is_inside_tree():
			queue_redraw()
@export var hitbox_offset: Vector2 = Vector2(0.0, -60.0):
	set(value):
		hitbox_offset = value
		_update_hitbox()
		if is_inside_tree():
			queue_redraw()

var collision_shape: CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	_update_hitbox()
	if Engine.is_editor_hint():
		queue_redraw()
		return
	health_component.initialize(max_health, 0)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	
	if team == 0:
		collision_layer = 2 # Player Base
	else:
		collision_layer = 4 # Enemy Base
	_update_hitbox()
	queue_redraw()

func _update_hitbox() -> void:
	if collision_shape and not is_instance_valid(collision_shape):
		collision_shape = null
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not collision_shape:
		return
	var rectangle := collision_shape.shape as RectangleShape2D
	if not rectangle:
		rectangle = RectangleShape2D.new()
		collision_shape.shape = rectangle
	if rectangle.size != hitbox_size:
		rectangle.size = hitbox_size
	if collision_shape.position != hitbox_offset:
		collision_shape.position = hitbox_offset

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_hitbox()

func _on_health_changed(cur: int, max_val: int) -> void:
	Events.base_damaged.emit(team, cur, max_val)

func _on_died() -> void:
	Events.base_destroyed.emit(team)

func _draw() -> void:
	# Keep completely invisible in-game so the background artwork remains pristine
	if Engine.is_editor_hint():
		var hitbox_rect := Rect2(hitbox_offset - hitbox_size * 0.5, hitbox_size)
		draw_rect(hitbox_rect, Color(1.0, 0.45, 0.2, 0.18), true)
		draw_rect(hitbox_rect, Color(1.0, 0.45, 0.2, 0.95), false, 2.0)
