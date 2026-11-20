# Lord of the Dungeon: 2D Tug-of-War Prototype Architecture Specification

> **For Hermes / Agent Squad:** Use this specification to implement and maintain the 2D Tug-of-War prototype in Godot 4.

**Goal:** Create a robust, modular, data-driven 2D Tug-of-War game prototype in Godot 4 (forward-compatible with Godot 4.x) featuring unit summoning, 1D lane combat, automated enemy waves, economy progression, and base destruction.

**Tech Stack:** Godot 4.x (GDScript 2.0 with static typing), 2D CanvasItems, CharacterBody2D, Area2D, Custom Resources (`.tres`).

---

## 1. System Architecture

### 1.1 Autoload Singletons
Singletons handle persistent global state, economy, signals, and session progression. Registered in `project.godot` under `[autoload]`.

```
res://scripts/autoload/
├── events.gd            # Global event bus for decoupled pub/sub signals
├── game_manager.gd      # Session lifecycle, game state machine, time scale
├── economy_manager.gd   # Player and enemy gold, passive income, transaction checks
└── wave_manager.gd      # Enemy wave progression, AI spawn director, pacing
```

#### A. Global Signal Bus (`events.gd`)
Decouples producers (units, bases, timers) from consumers (UI, audio, managers).
```gdscript
# res://scripts/autoload/events.gd
extends Node

# Economy Signals
signal gold_changed(team: int, new_amount: int, delta: int)

# Unit Lifecycle Signals
signal unit_spawn_requested(unit_id: StringName, team: int)
signal unit_spawned(unit: Node2D, team: int)
signal unit_died(unit: Node2D, team: int, gold_bounty: int)

# Combat Signals
signal damage_dealt(target: Node2D, amount: int, is_critical: bool)
signal base_damaged(team: int, current_hp: int, max_hp: int)
signal base_destroyed(losing_team: int)

# Game State Signals
signal game_state_changed(old_state: int, new_state: int)
signal wave_started(wave_number: int, wave_name: String)
signal wave_completed(wave_number: int)
```

#### B. Game Manager (`game_manager.gd`)
Controls game state flow: `MENU`, `PLAYING`, `PAUSED`, `VICTORY`, `DEFEAT`.
```gdscript
# res://scripts/autoload/game_manager.gd
extends Node

enum GameState { MENU, PLAYING, PAUSED, VICTORY, DEFEAT }
enum Team { PLAYER = 0, ENEMY = 1 }

var current_state: GameState = GameState.MENU

func _ready() -> void:
    Events.base_destroyed.connect(_on_base_destroyed)

func start_battle() -> void:
    change_state(GameState.PLAYING)
    Engine.time_scale = 1.0

func pause_battle(is_paused: bool) -> void:
    if current_state != GameState.PLAYING and current_state != GameState.PAUSED:
        return
    change_state(GameState.PAUSED if is_paused else GameState.PLAYING)
    get_tree().paused = is_paused

func change_state(new_state: GameState) -> void:
    if current_state == new_state:
        return
    var old_state: GameState = current_state
    current_state = new_state
    Events.game_state_changed.emit(old_state, new_state)

func _on_base_destroyed(losing_team: int) -> void:
    if losing_team == Team.ENEMY:
        change_state(GameState.VICTORY)
    else:
        change_state(GameState.DEFEAT)
```

#### C. Economy Manager (`economy_manager.gd`)
Tracks player and enemy gold reserves, executes passive income ticks, and validates purchases.
```gdscript
# res://scripts/autoload/economy_manager.gd
extends Node

@export var player_starting_gold: int = 100
@export var enemy_starting_gold: int = 100
@export var passive_income_rate: float = 5.0 # Gold per second
@export var income_tick_interval: float = 1.0

var player_gold: int = 0
var enemy_gold: int = 0
var _income_timer: float = 0.0

func _ready() -> void:
    Events.unit_died.connect(_on_unit_died)
    reset_economy()

func _process(delta: float) -> void:
    if GameManager.current_state != GameManager.GameState.PLAYING:
        return
    _income_timer += delta
    if _income_timer >= income_tick_interval:
        _income_timer -= income_tick_interval
        var tick_gold: int = int(passive_income_rate * income_tick_interval)
        add_gold(GameManager.Team.PLAYER, tick_gold)

func reset_economy() -> void:
    player_gold = player_starting_gold
    enemy_gold = enemy_starting_gold
    _income_timer = 0.0
    Events.gold_changed.emit(GameManager.Team.PLAYER, player_gold, 0)
    Events.gold_changed.emit(GameManager.Team.ENEMY, enemy_gold, 0)

func can_afford(team: int, cost: int) -> bool:
    if team == GameManager.Team.PLAYER:
        return player_gold >= cost
    return enemy_gold >= cost

func spend_gold(team: int, cost: int) -> bool:
    if not can_afford(team, cost):
        return false
    if team == GameManager.Team.PLAYER:
        player_gold -= cost
        Events.gold_changed.emit(team, player_gold, -cost)
    else:
        enemy_gold -= cost
        Events.gold_changed.emit(team, enemy_gold, -cost)
    return true

func add_gold(team: int, amount: int) -> void:
    if team == GameManager.Team.PLAYER:
        player_gold += amount
        Events.gold_changed.emit(team, player_gold, amount)
    else:
        enemy_gold += amount
        Events.gold_changed.emit(team, enemy_gold, amount)

func _on_unit_died(_unit: Node2D, team: int, gold_bounty: int) -> void:
    if gold_bounty <= 0:
        return
    # Killing enemy grants player gold, killing player unit grants enemy gold
    var beneficiary: int = GameManager.Team.PLAYER if team == GameManager.Team.ENEMY else GameManager.Team.ENEMY
    add_gold(beneficiary, gold_bounty)
```

---

## 2. Scene Hierarchy and Node Composition

```
res://
├── scenes/
│   ├── main.tscn                  # Root entry point, scene loader
│   ├── battle/
│   │   ├── battle_field.tscn      # 1D Arena, Camera, Lane, Spawners, Base nodes
│   │   └── lane.tscn              # Unit container and projectile manager
│   ├── base/
│   │   └── base.tscn              # Fortress / Dungeon portal scene
│   ├── units/
│   │   ├── unit_base.tscn         # Base CharacterBody2D template
│   │   ├── skeleton_warrior.tscn  # Melee brawler
│   │   ├── goblin_archer.tscn     # Ranged physical DPS
│   │   └── dark_mage.tscn         # Ranged magic DPS / summoner
│   ├── projectiles/
│   │   ├── projectile_base.tscn   # Base Area2D projectile
│   │   ├── arrow.tscn             # Linear ballistic projectile
│   │   └── shadow_orb.tscn        # Magic homing or piercing projectile
│   └── ui/
│       ├── hud.tscn               # Gold bar, wave status, base health bars
│       ├── unit_card.tscn         # Individual unit summon button with cooldown radial
│       └── game_over_modal.tscn   # Victory / Defeat screen
```

### 2.1 Battle Field Scene Tree (`res://scenes/battle/battle_field.tscn`)
```
BattleField (Node2D, script: battle_field.gd)
├── ParallaxBackground
│   ├── BackgroundLayer (Sky / Far Dungeon Backdrop)
│   └── MidgroundLayer (Stone pillars, torches)
├── Ground (StaticBody2D - sets reference Y level = 540)
│   └── CollisionShape2D (SegmentShape2D or WorldBoundary)
├── Camera2D (Horizontal clamp: min_x=0, max_x=1920, smoothed tracking / manual drag)
├── Lane (Node2D, script: lane.gd)
│   ├── PlayerUnits (Node2D, YSort or CanvasItem sort)
│   ├── EnemyUnits (Node2D, YSort or CanvasItem sort)
│   └── Projectiles (Node2D)
├── Bases
│   ├── PlayerBase (Instantiated base.tscn, position: X=120, Y=540, team=PLAYER)
│   └── EnemyBase (Instantiated base.tscn, position: X=1800, Y=540, team=ENEMY)
├── Spawners
│   ├── PlayerSpawner (Marker2D, position: X=180, Y=540)
│   └── EnemySpawner (Marker2D, position: X=1740, Y=540)
└── CanvasLayer (UI Root)
    └── HUD (Instantiated hud.tscn)
```

### 2.2 Base / Fortress Scene Tree (`res://scenes/base/base.tscn`)
```
Base (Area2D, script: base.gd, collision_layer=Layer 2/3, collision_mask=0)
├── VisualSprite (AnimatedSprite2D / Sprite2D)
├── CollisionShape2D (RectangleShape2D, sized 80x160)
├── HealthComponent (Node, script: health_component.gd)
├── HitboxReceiver (Area2D - triggers hurt signals from enemy attacks)
└── HealthBarUI (ProgressBar / TextureProgressBar attached above fortress)
```

### 2.3 Unit Base Scene Tree (`res://scenes/units/unit_base.tscn`)
```
UnitBase (CharacterBody2D, script: unit_base.gd)
├── AnimatedSprite2D (Visual animations: idle, move, attack, hurt, dead)
├── PhysicsCollision (CollisionShape2D, capsule or circle, disabled with teammates)
├── Components
│   ├── HealthComponent (Node, script: health_component.gd)
│   ├── CombatComponent (Node, script: combat_component.gd)
│   └── StateMachine (Node, script: state_machine.gd)
│       ├── IdleState (Node, script: unit_state_idle.gd)
│       ├── MoveState (Node, script: unit_state_move.gd)
│       ├── AttackState (Node, script: unit_state_attack.gd)
│       ├── HurtState (Node, script: unit_state_hurt.gd)
│       └── DeadState (Node, script: unit_state_dead.gd)
├── Sensors
│   ├── DetectionRayCast (RayCast2D - facing forward along horizontal axis)
│   └── MeleeHitbox (Area2D, monitors enemy hurtboxes on active attack frame)
│       └── CollisionShape2D
├── Timers
│   ├── AttackCooldownTimer (Timer, one_shot=true)
│   └── DespawnTimer (Timer, one_shot=true)
└── UnitUI
    └── OverheadHealthBar (TextureProgressBar, fades when full health)
```

---

## 3. Unit Finite State Machine (FSM) and Combat Logic

### 3.1 State Chart and Transitions
```
                +-------------------+
                |       IDLE        |
                +-------------------+
                     |         ^
   Enemy not in range|         | Lane blocked / Target lost
                     v         |
                +-------------------+
      +-------->|       MOVE        |<-------+
      |         +-------------------+        |
      |              |         ^             |
Target| Target enters|         | Attack ended|
dead  | range        v         | & no target |
      |         +-------------------+        |
      +---------|      ATTACK       |--------+
                +-------------------+
                          |
             Health <= 0  | (from any state)
                          v
                +-------------------+
                |       DEAD        |
                +-------------------+
```

### 3.2 1D Detection and Collision Matrix
- **Direction:** Player units face `+X` (vector `Vector2.RIGHT`), Enemy units face `-X` (vector `Vector2.LEFT`).
- **Layer Allocation:**
  - `Layer 1: World / Ground`
  - `Layer 2: Player Hurtbox (Base & Units)`
  - `Layer 3: Enemy Hurtbox (Base & Units)`
  - `Layer 4: Player Detection Area`
  - `Layer 5: Enemy Detection Area`
  - `Layer 6: Projectiles`

- **Detection Strategy:**
  1. `DetectionRayCast`: Length configured to `unit_data.attack_range`. Mask set strictly to opposing team hurtbox layer.
  2. Fallback / Secondary `DetectionArea2D`: Handles wide or vertical tolerance for units slightly offset on Y axis.
  3. When `DetectionRayCast.is_colliding()`, state transitions from `MOVE` to `ATTACK`. Target acquired from `get_collider()`.

### 3.3 State Machine Implementation Contracts

#### A. State Base Class (`unit_state.gd`)
```gdscript
# res://scripts/fsm/unit_state.gd
class_name UnitState
extends Node

var unit: UnitBase
var state_machine: UnitStateMachine

func enter(_msg: Dictionary = {}) -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    pass

func update(_delta: float) -> void:
    pass
```

#### B. State Machine Controller (`unit_state_machine.gd`)
```gdscript
# res://scripts/fsm/unit_state_machine.gd
class_name UnitStateMachine
extends Node

@export var initial_state: UnitState
var current_state: UnitState
var states: Dictionary = {}

func init(unit_node: UnitBase) -> void:
    for child in get_children():
        if child is UnitState:
            states[child.name.to_lower()] = child
            child.unit = unit_node
            child.state_machine = self
    if initial_state:
        transition_to(initial_state.name.to_lower())

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
    var normalized_name: String = target_state_name.to_lower()
    if not states.has(normalized_name):
        push_error("State %s does not exist in StateMachine" % target_state_name)
        return
    if current_state:
        current_state.exit()
    current_state = states[normalized_name]
    current_state.enter(msg)

func physics_update(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func update(delta: float) -> void:
    if current_state:
        current_state.update(delta)
```

#### C. Attack Cycle and Damage Resolution
- **Windup Phase:** State triggers attack animation.
- **Impact Frame:** Animation invokes method `_on_attack_hit_frame()` or frame event.
  - Melee: Calls `target.health_component.apply_damage(damage_amount, unit)`.
  - Ranged: Spawns projectile instance at fire point, initializing trajectory, speed, and damage payload.
- **Cooldown Phase:** Starts `AttackCooldownTimer`. Unit remains in `ATTACK` or enters brief `IDLE` until timer timeout.
- **Damage Formula:**
  $$\text{Damage Taken} = \max(1, \text{Attacker Damage} - \text{Target Armor})$$

---

## 4. Economic, Unit Definition, and Spawning Pipeline

### 4.1 Data-Driven Unit Definition (`unit_data.gd`)
Units are defined as Godot Custom Resources (`.tres`) for rapid balancing and zero-code unit authoring.

```gdscript
# res://scripts/resources/unit_data.gd
class_name UnitData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var unit_scene: PackedScene

@export_group("Economy")
@export var gold_cost: int = 25
@export var gold_bounty: int = 15
@export var spawn_cooldown: float = 3.0

@export_group("Combat Attributes")
@export var max_health: int = 100
@export var armor: int = 0
@export var move_speed: float = 80.0
@export var attack_damage: int = 15
@export var attack_range: float = 40.0
@export var attack_speed: float = 1.2 # Attacks per second
@export var is_ranged: bool = false
@export var projectile_scene: PackedScene
```

### 4.2 Spawning Pipeline
```
[User Clicks Unit Card / Hotkey]
             |
             v
[HUD / UnitCard validates EconomyManager.can_afford()]
             | (True)
             v
[EconomyManager.spend_gold() -> Events.unit_spawn_requested.emit()]
             |
             v
[BattleField / Spawner receives signal]
             |
             v
[Instantiate Unit Scene -> Assign Team -> Set Position -> Add to Lane]
             |
             v
[Events.unit_spawned.emit() -> UnitCard enters Cooldown Radial]
```

### 4.3 Automated Enemy Wave Progression (`wave_manager.gd`)
Waves are defined using a structured `WaveData` resource.

```gdscript
# res://scripts/resources/wave_data.gd
class_name WaveData
extends Resource

@export var wave_number: int = 1
@export var wave_title: String = "Skeletons Gathering"
@export var prep_time: float = 5.0
@export var spawn_sequences: Array[WaveSpawnEntry] = []

# res://scripts/resources/wave_spawn_entry.gd
class_name WaveSpawnEntry
extends Resource

@export var unit_data: UnitData
@export var spawn_delay: float = 2.0 # Delay after previous spawn
@export var count: int = 1
```

---

## 5. Complete Godot 4 Directory Structure (`res://`)

```
res://
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   │   └── clean_game_font.ttf
│   ├── shaders/
│   │   ├── hit_flash.gdshader
│   │   └── base_shield.gdshader
│   └── textures/
│       ├── backgrounds/
│       ├── bases/
│       ├── icons/
│       ├── projectiles/
│       ├── ui/
│       └── units/
│           ├── skeleton_warrior/
│           ├── goblin_archer/
│           └── dark_mage/
├── resources/
│   ├── units/
│   │   ├── player_skeleton_warrior.tres
│   │   ├── player_goblin_archer.tres
│   │   ├── player_dark_mage.tres
│   │   ├── enemy_skeleton_warrior.tres
│   │   ├── enemy_goblin_archer.tres
│   │   └── enemy_dark_mage.tres
│   └── waves/
│       ├── wave_01.tres
│       ├── wave_02.tres
│       ├── wave_03.tres
│       └── wave_boss.tres
├── scenes/
│   ├── base/
│   │   └── base.tscn
│   ├── battle/
│   │   ├── battle_field.tscn
│   │   └── lane.tscn
│   ├── main.tscn
│   ├── projectiles/
│   │   ├── arrow.tscn
│   │   ├── projectile_base.tscn
│   │   └── shadow_orb.tscn
│   ├── ui/
│   │   ├── game_over_modal.tscn
│   │   ├── hud.tscn
│   │   └── unit_card.tscn
│   └── units/
│       ├── dark_mage.tscn
│       ├── goblin_archer.tscn
│       ├── skeleton_warrior.tscn
│       └── unit_base.tscn
└── scripts/
    ├── autoload/
    │   ├── economy_manager.gd
    │   ├── events.gd
    │   ├── game_manager.gd
    │   └── wave_manager.gd
    ├── base/
    │   └── base.gd
    ├── battle/
    │   ├── battle_field.gd
    │   ├── lane.gd
    │   └── spawner.gd
    ├── components/
    │   ├── combat_component.gd
    │   ├── health_component.gd
    │   └── hitbox_component.gd
    ├── fsm/
    │   ├── unit_state.gd
    │   ├── unit_state_attack.gd
    │   ├── unit_state_dead.gd
    │   ├── unit_state_hurt.gd
    │   ├── unit_state_idle.gd
    │   ├── unit_state_machine.gd
    │   └── unit_state_move.gd
    ├── projectiles/
    │   └── projectile_base.gd
    ├── resources/
    │   ├── unit_data.gd
    │   ├── wave_data.gd
    │   └── wave_spawn_entry.gd
    ├── ui/
    │   ├── game_over_modal.gd
    │   ├── hud.gd
    │   └── unit_card.gd
    └── units/
        └── unit_base.gd
```

---

## 6. Verification and Acceptance Criteria

1. **Scene Decoupling:** Every scene runs standalone in the Godot editor without crashing (Base, UnitBase, HUD, BattleField).
2. **Deterministic 1D Movement:** Units spawn at the designated X marker, advance strictly along the horizontal axis, and halt within their configured `attack_range` upon encountering opposing targets.
3. **Robust State Switching:** Units transition reliably between `MOVE`, `ATTACK`, and `DEAD` without deadlocks, dropped animation frames, or lingering raycast colliders.
4. **Economy Integrity:** Spawning checks balance, deducts exact unit cost, enforces cooldowns, and awards the correct bounty upon enemy death.
5. **Base Destruction Win/Loss:** Depleting the health of either base immediately emits `base_destroyed`, halts unit spawning, and triggers the `VICTORY` or `DEFEAT` modal.
