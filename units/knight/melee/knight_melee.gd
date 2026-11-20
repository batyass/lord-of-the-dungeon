extends melee_unit

var hit_sfx

func _ready():
	health = 110
	damage = 22
	move_speed = 70
	money_die_reward = 20
	
	sprite_walk_position = Vector2(0, -45)
	sprite_idle_position = Vector2(0, -45)
	sprite_die_position = Vector2(0, -45)
	sprite_attack_position = Vector2(0, -45)
	
	hit_sfx = get_node_or_null("sfx/hit_sfx")
	super()
	
	if is_player_owned == false and has_node("Shadow"):
		$Shadow.position.x = -$Shadow.position.x

func _process(delta):
	super(delta)

func attack_state():
	if $RayCast2D.is_colliding() == false:
		change_state(state.walk)
		stop_all_sfx()
		return
	
	if $AnimatedSprite2D.frame == 4:
		if hit_sfx:
			hit_sfx.play()
		do_damage($RayCast2D.get_collider())
