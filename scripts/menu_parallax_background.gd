extends ParallaxBackground

@export var use_x: bool = true
@export var use_y: bool = true
@export var parallax_x_strength: float = 12.0
@export var parallax_y_strength: float = 6.0
@export var smooth_speed: float = 4.0

var _target_offset := Vector2.ZERO

func _ready() -> void:
	update_parallax(1.0)

func _process(delta: float) -> void:
	update_parallax(delta)

func update_parallax(delta: float) -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	var vp_size = viewport.get_visible_rect().size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	var mouse_pos = viewport.get_mouse_position()
	var norm_x = (mouse_pos.x / vp_size.x) - 0.5
	var norm_y = (mouse_pos.y / vp_size.y) - 0.5
	
	_target_offset.x = -norm_x * parallax_x_strength if use_x else 0.0
	_target_offset.y = -norm_y * parallax_y_strength if use_y else 0.0
	
	if delta >= 1.0:
		scroll_offset = _target_offset
	else:
		scroll_offset = scroll_offset.lerp(_target_offset, clampf(delta * smooth_speed, 0.0, 1.0))
