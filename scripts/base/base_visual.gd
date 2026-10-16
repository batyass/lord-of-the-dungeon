class_name BaseVisual
extends Node2D

@export var is_player: bool = true

func _draw() -> void:
	if is_player:
		# Player Dungeon Core / Obsidian Throne
		var base_color = Color(0.1, 0.08, 0.16) # Obsidian
		var accent_color = Color(0.48, 0.17, 0.75) # Necrotic purple
		var glow_color = Color(0.78, 0.49, 1.0) # Necrotic glow
		
		# Tower Body
		draw_rect(Rect2(-40, -140, 80, 140), base_color)
		draw_rect(Rect2(-45, -160, 90, 20), Color(0.15, 0.12, 0.22))
		
		# Buttresses
		draw_polygon(PackedVector2Array([Vector2(-40, 0), Vector2(-60, 0), Vector2(-40, -60)]), [base_color])
		draw_polygon(PackedVector2Array([Vector2(40, 0), Vector2(60, 0), Vector2(40, -60)]), [base_color])
		
		# Battlements / Spikes
		draw_rect(Rect2(-45, -175, 18, 15), Color(0.2, 0.15, 0.3))
		draw_rect(Rect2(-9, -175, 18, 15), Color(0.2, 0.15, 0.3))
		draw_rect(Rect2(27, -175, 18, 15), Color(0.2, 0.15, 0.3))
		
		# Glowing Dungeon Portal / Runic Core
		draw_circle(Vector2(0, -70), 24, accent_color)
		draw_circle(Vector2(0, -70), 16, glow_color)
		draw_circle(Vector2(0, -70), 8, Color(1, 1, 1, 0.9))
		
		# Runic frame lines
		draw_line(Vector2(-30, -20), Vector2(30, -20), glow_color, 2.0)
		draw_line(Vector2(-30, -120), Vector2(30, -120), glow_color, 2.0)
	else:
		# Enemy Crusader Fortress / Holy Portal
		var base_color = Color(0.22, 0.20, 0.26) # Stone grey
		var accent_color = Color(0.9, 0.7, 0.1) # Holy gold
		var crest_color = Color(0.85, 0.2, 0.25) # Crusader crimson
		
		# Tower Body
		draw_rect(Rect2(-40, -140, 80, 140), base_color)
		draw_rect(Rect2(-45, -160, 90, 20), Color(0.3, 0.28, 0.35))
		
		# Buttresses
		draw_polygon(PackedVector2Array([Vector2(-40, 0), Vector2(-60, 0), Vector2(-40, -60)]), [base_color])
		draw_polygon(PackedVector2Array([Vector2(40, 0), Vector2(60, 0), Vector2(40, -60)]), [base_color])
		
		# Battlements
		draw_rect(Rect2(-45, -175, 18, 15), Color(0.35, 0.33, 0.4))
		draw_rect(Rect2(-9, -175, 18, 15), Color(0.35, 0.33, 0.4))
		draw_rect(Rect2(27, -175, 18, 15), Color(0.35, 0.33, 0.4))
		
		# Gilded Gate / Portal
		draw_circle(Vector2(0, -70), 24, crest_color)
		draw_circle(Vector2(0, -70), 16, accent_color)
		draw_circle(Vector2(0, -70), 8, Color(1, 0.95, 0.7))
		
		# Crusader Cross / Banner
		draw_line(Vector2(0, -95), Vector2(0, -45), Color.WHITE, 3.0)
		draw_line(Vector2(-15, -70), Vector2(15, -70), Color.WHITE, 3.0)
