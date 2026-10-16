extends Area2D
class_name ProjectileBase

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0
var damage: int = 20
var team: int = 0
var lifetime: float = 3.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func launch(start_pos: Vector2, target_pos: Vector2, p_team: int, p_damage: int, p_speed: float) -> void:
	global_position = start_pos
	team = p_team
	damage = p_damage
	speed = p_speed
	direction = (target_pos - start_pos).normalized()
	rotation = direction.angle()
	queue_redraw()

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	z_as_relative = false
	z_index = clampi(roundi(global_position.y), -4095, 4095) + 1
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	_check_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_check_hit(area)

func _check_hit(target: Node2D) -> void:
	if not target or not is_instance_valid(target) or is_queued_for_deletion():
		return
	if "team" in target and target.team != team:
		if target.has_node("HealthComponent"):
			target.get_node("HealthComponent").take_damage(damage)
		elif target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()

func _draw() -> void:
	var color_core = Color(1.0, 0.7, 0.2, 1.0) if team == 0 else Color(0.2, 0.8, 1.0, 1.0)
	var color_glow = Color(1.0, 0.2, 0.0, 0.6) if team == 0 else Color(0.1, 0.4, 1.0, 0.6)
	draw_circle(Vector2.ZERO, 6.0, color_glow)
	draw_circle(Vector2.ZERO, 3.5, color_core)
	draw_line(Vector2(-12, 0), Vector2(6, 0), color_core, 2.5)
