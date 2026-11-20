extends range_unit

var shoot_sfx

func _ready():
	health = 75
	damage = 25
	move_speed = 65
	money_die_reward = 35
	
	sprite_walk_position = Vector2(0, -45)
	sprite_idle_position = Vector2(0, -45)
	sprite_die_position = Vector2(0, -45)
	sprite_idle_attack_position = Vector2(0, -45)
	sprite_melee_attack_position = Vector2(0, -45)
	
	shoot_sfx = get_node_or_null("sfx/shoot_sfx")
	super()
	
	if is_player_owned == false and has_node("Shadow"):
		$Shadow.position.x = -$Shadow.position.x

func _process(delta):
	super(delta)

func idle_attack_state():
	if range_ray_cast.is_colliding() == false:
		change_state(state.walk)
		return
	
	if $AnimatedSprite2D.frame == 3:
		if shoot_sfx:
			shoot_sfx.play()
		if range_ray_cast.get_collider():
			do_damage(range_ray_cast.get_collider())

func melee_attack_state():
	if melee_ray_cast.is_colliding() == false:
		change_state(state.walk)
		return
	
	if $AnimatedSprite2D.frame == 3:
		if melee_ray_cast.get_collider():
			do_damage(melee_ray_cast.get_collider())
