class_name UnitVisual
extends Node2D

@export var unit_type: String = "skeleton"
@export var is_player: bool = true

var current_anim: String = "idle"
var anim_time: float = 0.0
var flash_color: Color = Color(1, 1, 1, 1)
var is_flashing: bool = false

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func set_animation(anim_name: String) -> void:
	current_anim = anim_name
	anim_time = 0.0
	queue_redraw()

func trigger_hurt_flash() -> void:
	is_flashing = true
	var tween = create_tween()
	tween.tween_property(self, "flash_color", Color(2.0, 0.4, 0.4, 1.0), 0.06)
	tween.tween_property(self, "flash_color", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	tween.tween_callback(func(): is_flashing = false)

func _draw() -> void:
	var dir_mult = 1.0 if is_player else -1.0
	var offset_y = 0.0
	var rot_offset = 0.0
	var scale_x = dir_mult
	
	if current_anim == "idle":
		offset_y = sin(anim_time * 4.0) * 2.0
	elif current_anim == "move":
		offset_y = abs(sin(anim_time * 8.0)) * -4.0
		rot_offset = sin(anim_time * 8.0) * 0.08 * dir_mult
	elif current_anim == "attack":
		var progress = min(1.0, anim_time * 4.0)
		offset_y = 0.0
		scale_x = dir_mult * (1.0 + sin(progress * PI) * 0.25)
	
	draw_set_transform(Vector2(0, offset_y), rot_offset, Vector2(scale_x, 1.0))
	
	var base_tint = flash_color if is_flashing else Color.WHITE
	
	match unit_type:
		"bat":
			_draw_bat(base_tint)
		"skeleton":
			_draw_skeleton(base_tint)
		"golem":
			_draw_golem(base_tint)
		"enemy_warrior":
			_draw_enemy_warrior(base_tint)
		"enemy_archer":
			_draw_enemy_archer(base_tint)
		_:
			_draw_skeleton(base_tint)

func _draw_bat(tint: Color) -> void:
	var body_col = Color(0.35, 0.15, 0.45) * tint
	var wing_col = Color(0.55, 0.25, 0.7) * tint
	var eye_col = Color(1.0, 0.2, 0.3)
	
	# Bat Body (Flying Y = -28)
	draw_circle(Vector2(0, -28), 10, body_col)
	# Ears
	draw_polygon(PackedVector2Array([Vector2(-6, -34), Vector2(-2, -42), Vector2(0, -34)]), [body_col])
	draw_polygon(PackedVector2Array([Vector2(6, -34), Vector2(2, -42), Vector2(0, -34)]), [body_col])
	# Eyes
	draw_circle(Vector2(4, -30), 2.5, eye_col)
	# Wings flapping
	var wing_flap = sin(anim_time * 14.0) * 12.0
	draw_polygon(PackedVector2Array([Vector2(-4, -28), Vector2(-22, -34 + wing_flap), Vector2(-16, -20 + wing_flap)]), [wing_col])
	draw_polygon(PackedVector2Array([Vector2(4, -28), Vector2(22, -34 + wing_flap), Vector2(16, -20 + wing_flap)]), [wing_col])

func _draw_skeleton(tint: Color) -> void:
	var bone_col = Color(0.88, 0.88, 0.85) * tint
	var eye_col = Color(0.48, 0.17, 0.75)
	var sword_col = Color(0.7, 0.75, 0.8) * tint
	
	# Head
	draw_circle(Vector2(0, -38), 9, bone_col)
	# Eye socket
	draw_circle(Vector2(3, -39), 2.2, eye_col)
	# Ribcage / Body
	draw_rect(Rect2(-5, -28, 10, 14), bone_col)
	draw_line(Vector2(-7, -25), Vector2(7, -25), bone_col, 2.0)
	draw_line(Vector2(-6, -20), Vector2(6, -20), bone_col, 2.0)
	# Legs
	draw_line(Vector2(-3, -14), Vector2(-4, 0), bone_col, 2.5)
	draw_line(Vector2(3, -14), Vector2(4, 0), bone_col, 2.5)
	# Sword
	draw_line(Vector2(8, -26), Vector2(18, -36), sword_col, 3.0)
	draw_line(Vector2(5, -24), Vector2(11, -22), Color(0.4, 0.3, 0.2), 2.0)

func _draw_golem(tint: Color) -> void:
	var rock_col = Color(0.22, 0.2, 0.28) * tint
	var core_col = Color(0.78, 0.49, 1.0)
	
	# Massive Torso
	draw_rect(Rect2(-16, -45, 32, 32), rock_col)
	# Glowing Core
	draw_circle(Vector2(0, -30), 7, core_col)
	draw_circle(Vector2(0, -30), 4, Color(1, 1, 1, 0.9))
	# Rock Head
	draw_rect(Rect2(-10, -56, 20, 12), rock_col)
	draw_circle(Vector2(4, -50), 3, core_col)
	# Heavy Arms
	draw_rect(Rect2(-24, -42, 9, 26), rock_col)
	draw_rect(Rect2(15, -42, 9, 26), rock_col)
	# Legs
	draw_rect(Rect2(-12, -13, 10, 13), rock_col)
	draw_rect(Rect2(2, -13, 10, 13), rock_col)

func _draw_enemy_warrior(tint: Color) -> void:
	var armor_col = Color(0.75, 0.75, 0.8) * tint
	var tunic_col = Color(0.85, 0.2, 0.25) * tint
	var shield_col = Color(0.9, 0.7, 0.1) * tint
	
	# Helmet
	draw_circle(Vector2(0, -38), 9, armor_col)
	draw_line(Vector2(-4, -38), Vector2(4, -38), Color(0.1, 0.1, 0.1), 2.0)
	# Torso & Tunic
	draw_rect(Rect2(-6, -28, 12, 16), tunic_col)
	# Legs
	draw_line(Vector2(-3, -12), Vector2(-3, 0), armor_col, 3.0)
	draw_line(Vector2(3, -12), Vector2(3, 0), armor_col, 3.0)
	# Shield
	draw_rect(Rect2(5, -30, 8, 16), shield_col)
	draw_line(Vector2(9, -28), Vector2(9, -16), Color.WHITE, 2.0)
	# Sword
	draw_line(Vector2(-7, -24), Vector2(-15, -32), armor_col, 2.5)

func _draw_enemy_archer(tint: Color) -> void:
	var cloak_col = Color(0.2, 0.45, 0.3) * tint
	var skin_col = Color(0.9, 0.8, 0.7) * tint
	var bow_col = Color(0.55, 0.35, 0.2) * tint
	
	# Hood
	draw_circle(Vector2(0, -36), 8, cloak_col)
	draw_circle(Vector2(2, -35), 2.0, skin_col)
	# Cloak Body
	draw_polygon(PackedVector2Array([Vector2(-6, -28), Vector2(6, -28), Vector2(8, -4), Vector2(-8, -4)]), [cloak_col])
	# Legs
	draw_line(Vector2(-3, -4), Vector2(-3, 0), Color(0.3, 0.2, 0.1), 2.5)
	draw_line(Vector2(3, -4), Vector2(3, 0), Color(0.3, 0.2, 0.1), 2.5)
	# Bow
	draw_arc(Vector2(10, -24), 10, -PI * 0.4, PI * 0.4, 8, bow_col, 2.0)
	draw_line(Vector2(10, -32), Vector2(10, -16), Color(0.9, 0.9, 0.9, 0.6), 1.0)
