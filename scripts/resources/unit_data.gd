extends Resource
class_name UnitData

@export var id: StringName = &"skeleton"
@export var display_name: String = "Squelette Guerrier"
@export var gold_cost: int = 50
@export var gold_bounty: int = 25
@export var spawn_cooldown: float = 3.0

@export_group("Combat Stats")
@export var max_health: int = 100
@export var armor: int = 2
@export var move_speed: float = 80.0
@export var attack_damage: int = 20
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
@export var is_ranged: bool = false
@export var projectile_speed: float = 300.0

@export_group("Sprites & Animations")
@export var texture_walk: Texture2D
@export var walk_frames: int = 4
@export var texture_attack: Texture2D
@export var attack_frames: int = 8
@export var texture_death: Texture2D
@export var death_frames: int = 4
@export var sprite_scale: Vector2 = Vector2(1.2, 1.2)
@export var sprite_offset_y: float = -30.0
@export var unit_color: Color = Color.WHITE
@export var size_radius: float = 18.0
