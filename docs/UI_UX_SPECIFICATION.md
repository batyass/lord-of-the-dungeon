# Lord of the Dungeon: UI/UX & HUD Design Specification

## 1. Canvas & Viewport Architecture

### 1.1 Resolution and Scaling Rules
- Base Viewport: 1280x720 (16:9 widescreen)
- Stretch Mode: canvas_items
- Stretch Aspect: expand
- Target Framerate: 60 FPS (Vsync enabled)
- Safe Margin: 16px padding on all screen borders for HUD elements

### 1.2 Screen Grid & Spatial Zones (1280 x 720)
```
+-------------------------------------------------------------------------------+ (0,0)
| [TOP HEADER BAR] (Y: 0 to 72, Height: 72px, Full Width 1280px)                 |
| - Left: Player Castle HP Bar       - Center: Wave Counter  - Right: Gold HUD  |
+-------------------------------------------------------------------------------+ (Y: 72)
|                                                                               |
|                                                                               |
|                           [2D COMBAT LANE VIEWPORT]                           |
|                      (Y: 72 to 580, Height: 508px)                            |
|             Left: Player Base <--- 1D Lane ---> Right: Enemy Base             |
|                                                                               |
|                                                                               |
+-------------------------------------------------------------------------------+ (Y: 580)
| [BOTTOM ACTION BAR] (Y: 580 to 704, Height: 124px, 8px Bottom Margin)         |
| - Left/Center: Unit Summon Cards (Bat, Skeleton, Golem)                       |
| - Right: Meteor Emergency Spell + Tactical Controls                           |
+-------------------------------------------------------------------------------+ (Y: 720)
```

---

## 2. HUD Layout Specifications

### 2.1 Top Header Bar (Y: 0 to 72, X: 16 to 1264)
- Container: MarginContainer (Offsets: Top 12, Left 16, Right -16, Bottom 68) with HBoxContainer layout.

#### A. Player Castle HP Bar (Left Anchor: X=16 to 380, W=364px, H=44px)
- Visual Composition:
  - Base Frame: 9-slice ornate obsidian border (4px corner radius) with dark purple runic filigree.
  - Core Icon: 36x36px glowing purple dungeon portal / fortress crest on the left edge.
  - Dual-Layer Health Bar:
    - Background: Deep void burgundy (#1F080C).
    - Under-Layer (Damage Ghost Bar): Spectral amber (#E09F3E) with 0.4s delay tween for visual hit impact.
    - Top Fill Bar: Blood crimson gradient (#9B1D28 to #E63946).
  - Text Overlay: Centered Label "2500 / 2500 HP", bold 14pt with 2px dark outline (#0B0A10).
  - Low Health State (< 25% HP): Pulsing red vignette edge + warning heartbeat ping on the frame.

#### B. Wave Progress Indicator (Center Anchor: X=490 to 790, W=300px, H=48px)
- Visual Composition:
  - Background: Inset dark stone plate (#14121E) with gilded carved border (#7B2CBF / #FFB703).
  - Header Tag: "WAVE 03 / 10" in lustrous gold (#FFB703, 16pt bold).
  - Sub-Progress Bar (W=240px, H=8px):
    - Smooth linear progress showing wave completion percentage or incoming wave timer.
    - Segment markers indicating mini-boss and elite wave thresholds.
  - Wave Transition Alert: Big centered animated banner sliding down on wave start: "WAVE 4: UNDEAD HORDE" with sound trigger.

#### C. Gold Treasury HUD (Right Anchor: X=960 to 1264, W=304px, H=44px)
- Visual Composition:
  - Coin Crest: 32x32px embossed gold coin with rotating shimmer shader.
  - Numeric Counter: Dynamic Label "145g" (20pt bold, color #FFB703, scales up 1.1x on gold gain).
  - Income Rate Subtext: "+5g/s" badge in muted emerald (#06D6A0, 12pt).
  - Insufficient Funds Visual: Numerical counter briefly flashes red (#E63946) when trying to buy an unaffordable unit.

---

### 2.2 Bottom Action Bar (Y: 580 to 704, Height: 124px)
- Container: PanelContainer pinned to bottom with semi-transparent gradient mask (#0B0A10CC) to ground the UI without obstructing lane ground visuals.

#### A. Unit Summon Cards (Centered HBoxContainer: X=240 to 760, Spacing: 16px)

1. Card 1: Bat / Slime (Swarm Scout)
   - Cost: 20 Gold
   - Cooldown: 1.5s
   - Keybind: [1]
   - Card Dimensions: 96px width x 108px height.
   - Card Portrait: Violet winged bat silhouette over dark cavern backdrop.
   - Cost Pill: Top-right corner, 36x20px gold badge with coin icon + "20".
   - Keybind Pill: Top-left corner, 20x20px stone square with letter "1".
   - Radial Cooldown Overlay: TextureProgressBar (Fill mode: Clockwise 360 radial) tinted black at 65% opacity.

2. Card 2: Skeleton Warrior (Frontline Brawler)
   - Cost: 50 Gold
   - Cooldown: 4.0s
   - Keybind: [2]
   - Card Dimensions: 96px width x 108px height.
   - Card Portrait: Iron-armored skeleton clutching a broadsword.
   - Cost Pill: Top-right, "50g".
   - Keybind Pill: Top-left, "2".
   - Radial Cooldown Overlay: Clockwise sweep + digital cooldown countdown (e.g., "3.2s") centered in bold 14pt.

3. Card 3: Abyssal Golem (Heavy Siege Tank)
   - Cost: 120 Gold
   - Cooldown: 12.0s
   - Keybind: [3]
   - Card Dimensions: 96px width x 108px height.
   - Card Portrait: Massive runic obsidian construct with glowing purple fissures.
   - Cost Pill: Top-right, "120g".
   - Keybind Pill: Top-left, "3".
   - Radial Cooldown Overlay: Clockwise sweep + digital countdown.

#### B. Card State Transitions
- Available (Affordable + Cooldown Ready): Bright border (#7B2CBF), full color saturation, gold cost in bright yellow (#FFD166).
- Hover: 1.04x scale tween, border changes to luminous gold (#FFB703), audio tick SFX.
- Pressed / Spawned: 0.96x punch down, gold deducted, radial cooldown begins.
- Unaffordable (Gold < Cost): 50% desaturation, cost number displayed in crimson (#FF6B6B), card remains clickable to trigger 'Cannot Afford' audio cue.
- Cooldown Active: Dark overlay with radial sweep; hotkey and click inputs locked.

#### C. Emergency Spell Button: Meteor Strike (X=800 to 920, W=100px, H=108px)
- Visual Composition:
  - Frame: Circular or hexagonal heavy runic seal (88x88px button).
  - Icon: Fiery abyssal meteor plunging downward.
  - Hotkey Badge: Bottom-center pill "[SPACE]" in high-contrast ivory (#F0E6D2).
  - Cooldown: 30.0s radial sweep.
  - Ready State: Pulsing flame particle effect around the border.
  - Active Cast: Screen flash + screen shake + lane impact effect wiping low-tier enemy units.

#### D. Tactical Utilities (X=960 to 1264)
- Game Speed Toggle: 1x / 2x speed pill button [TAB].
- Pause / Settings Button: 44x44px gear icon [ESC].

---

## 3. Color Palette & Dark Fantasy Visual Tokens

```
================================================================================
TOKEN CATEGORY       TOKEN NAME          HEX VALUE       USAGE / ROLE
================================================================================
Base & Surfaces      bg-void             #0B0A10         Canvas base, dark vignettes
                     panel-obsidian      #14121E         HUD cards, modal bodies
                     surface-raised      #211D30         Button normals, container wells
                     border-dark         #38304D         Subtle frame strokes (1px)
                     border-highlight    #5A4D7A         Active container highlight

Accents & Soul       accent-gold         #FFB703         Primary economy, victory title
                     gold-light          #FFF0A5         Specular highlights, sparkles
                     gold-dark           #D48B00         Gold borders, shadow shades
                     blood-crimson       #E63946         Player HP fill, defeat title
                     blood-dark          #9B1D28         HP background shadow
                     necrotic-purple     #7B2CBF         Magic runes, player portals
                     necrotic-glow       #C77DFF         Spell glows, active borders
                     spectral-teal       #00F5D4         Buffs, wave progress bar

Text & Typography    text-primary        #FFFFFF         Primary headers, bold readouts
                     text-secondary      #D0C9DB         Subtext, descriptions, rates
                     text-muted          #7A738A         Disabled labels, hotkey tints
                     text-danger         #FF6B6B         Cannot afford, low HP alerts
================================================================================
```

### Typography Hierarchy (Godot Control Theme)
- H1 (Modal Titles / Victory & Defeat): 36pt Bold, All-Caps, Drop Shadow (0, 3) #0B0A10.
- H2 (Wave Announcements / Section Headers): 22pt Semi-Bold, Color #FFB703 / #C77DFF.
- Body Large (Gold Counter, Big HP Values): 18pt Bold, Outline 2px #0B0A10.
- Body Regular (Unit Card Names, Descriptions): 14pt Medium, Color #D0C9DB.
- Badges & Keybinds: 11pt Bold, Monospace/Clean Sans, Color #FFF0A5.

---

## 4. Victory & Defeat Modal Overlays

### 4.1 Transition & Screen Flow
1. Condition: `Events.base_destroyed` emitted by either Base.
2. Freeze / Slowdown: `Engine.time_scale` smoothly tweens from 1.0 to 0.2 over 0.8s.
3. Backdrop Dim: Fullscreen `ColorRect` (#050408) fades in to 0.80 opacity with slight blur.
4. Modal Entry: Modal panel scales from 0.85 to 1.0 with BackEaseOut curve over 0.4s.

### 4.2 Victory Modal Layout (res://scenes/ui/victory_modal.tscn)
```
+-------------------------------------------------------------------+
|                        [ VICTORY BANNER ]                         |
|            *** VICTORY: THE DUNGEON IS CONQUERED ***              |
|                     (36pt Gold #FFB703 Glow)                      |
+-------------------------------------------------------------------+
|                                                                   |
|   +-----------------------------------------------------------+   |
|   |                      BATTLE REPORT                        |   |
|   |                                                           |   |
|   |   Waves Repelled:                   10 / 10               |   |
|   |   Gold Plundered:                   1,840g                |   |
|   |   Minions Summoned:                 46                    |   |
|   |   Core Integrity:                   84% (2100/2500 HP)    |   |
|   |   Battle Duration:                  04m 18s               |   |
|   +-----------------------------------------------------------+   |
|                                                                   |
|   [  CONTINUE / REPLAY  ]                  [  RETURN TO MENU  ]   |
|   (Primary Gold Button)                    (Slate Outline)        |
+-------------------------------------------------------------------+
```

### 4.3 Defeat Modal Layout (res://scenes/ui/defeat_modal.tscn)
```
+-------------------------------------------------------------------+
|                         [ DEFEAT BANNER ]                         |
|              *** DEFEAT: YOUR CORE HAS FALLEN ***                 |
|                   (36pt Blood Crimson #E63946)                    |
+-------------------------------------------------------------------+
|                                                                   |
|   +-----------------------------------------------------------+   |
|   |                      DEFEAT REPORT                        |   |
|   |                                                           |   |
|   |   Farthest Wave:                    Wave 07               |   |
|   |   Enemies Slain:                    74                    |   |
|   |   Gold Earned:                      920g                  |   |
|   |   Survival Time:                    03m 12s               |   |
|   +-----------------------------------------------------------+   |
|                                                                   |
|   [     RETRY BATTLE    ]                  [  RETURN TO MENU  ]   |
|   (Crimson Accent Button)                  (Slate Outline)        |
+-------------------------------------------------------------------+
```

---

## 5. Godot 4 Control Node Hierarchy (`res://scenes/ui/hud.tscn`)

```
HUD (CanvasLayer - layer=10)
└── HUDControl (Control - anchors_preset=15 Full Rect, mouse_filter=Ignore)
    ├── TopBarMargin (MarginContainer - offsets: L16, T12, R-16, B68)
    │   └── TopHBox (HBoxContainer - alignment=Center)
    │       ├── PlayerBaseHUD (PanelContainer - custom_minimum_size: 340x48)
    │       │   └── MarginContainer (offsets: 6px all around)
    │       │       └── HBoxContainer
    │       │           ├── BaseIcon (TextureRect - 36x36 portal icon)
    │       │           └── VBoxContainer (alignment=Center)
    │       │               ├── TitleLabel (Label: "DUNGEON CORE", 11pt, #D0C9DB)
    │       │               └── HealthBarContainer (Control - custom_min: 260x18)
    │       │                   ├── GhostHealthBar (ProgressBar - color: #E09F3E)
    │       │                   ├── MainHealthBar (ProgressBar - color: #E63946)
    │       │                   └── HPLabel (Label: "2500 / 2500", center aligned)
    │       │
    │       ├── SpacerLeft (Control - size_flags_horizontal=Expand)
    │       │
    │       ├── WaveHUD (PanelContainer - custom_minimum_size: 280x48)
    │       │   └── VBoxContainer (alignment=Center)
    │       │       ├── WaveTitleLabel (Label: "WAVE 3 / 10", 15pt bold, #FFB703)
    │       │       └── WaveProgressBar (ProgressBar - custom_min: 220x6, #00F5D4)
    │       │
    │       ├── SpacerRight (Control - size_flags_horizontal=Expand)
    │       │
    │       └── GoldHUD (PanelContainer - custom_minimum_size: 200x48)
    │           └── MarginContainer (offsets: 6px all around)
    │               └── HBoxContainer (alignment=Center, separation=8)
    │                   ├── CoinIcon (TextureRect - 32x32 gold coin)
    │                   └── VBoxContainer
    │                       ├── GoldAmountLabel (Label: "150g", 18pt bold, #FFB703)
    │                       └── IncomeRateLabel (Label: "+5/s", 11pt, #06D6A0)
    │
    ├── BottomBarMargin (MarginContainer - anchor_bottom=1.0, offsets: L16, T-132, R-16, B-12)
    │   └── BottomHBox (HBoxContainer - alignment=Center, separation=20)
    │       ├── UnitsCardHBox (HBoxContainer - separation=14)
    │       │   ├── UnitCard_Bat (Instantiated unit_card.tscn, unit_id="bat", cost=20, keybind="1")
    │       │   ├── UnitCard_Skeleton (Instantiated unit_card.tscn, unit_id="skeleton", cost=50, keybind="2")
    │       │   └── UnitCard_Golem (Instantiated unit_card.tscn, unit_id="golem", cost=120, keybind="3")
    │       │
    │       ├── ActionSeparator (VSeparator - color: #38304D)
    │       │
    │       ├── SpellButton_Meteor (Button / TextureButton - custom_min: 96x104)
    │       │   ├── SpellIcon (TextureRect)
    │       │   ├── CooldownRadial (TextureProgressBar - fill_mode=RadialClockwise)
    │       │   ├── CooldownLabel (Label: "30.0s", center)
    │       │   └── KeybindBadge (PanelContainer - bottom center, label: "SPACE")
    │       │
    │       └── UtilityVBox (VBoxContainer - alignment=Center, separation=8)
    │           ├── SpeedButton (Button: "SPEED 1X / 2X")
    │           └── PauseButton (Button: "PAUSE [ESC]")
    │
    └── GameOverModal (Instantiated game_over_modal.tscn - visible=false)
```

---

## 6. Component Mockup Script Contracts

### 6.1 `hud.gd` (HUD Controller)
```gdscript
extends CanvasLayer

@onready var hp_bar: ProgressBar = %MainHealthBar
@onready var ghost_hp_bar: ProgressBar = %GhostHealthBar
@onready var hp_label: Label = %HPLabel
@onready var gold_label: Label = %GoldAmountLabel
@onready var wave_title: Label = %WaveTitleLabel
@onready var wave_bar: ProgressBar = %WaveProgressBar
@onready var meteor_radial: TextureProgressBar = %MeteorCooldownRadial
@onready var meteor_label: Label = %MeteorCooldownLabel

var _meteor_cooldown_max: float = 30.0
var _meteor_cooldown_left: float = 0.0

func _ready() -> void:
    Events.gold_changed.connect(_on_gold_changed)
    Events.base_damaged.connect(_on_base_damaged)
    Events.wave_started.connect(_on_wave_started)
    Events.game_state_changed.connect(_on_game_state_changed)

func _process(delta: float) -> void:
    if _meteor_cooldown_left > 0.0:
        _meteor_cooldown_left = max(0.0, _meteor_cooldown_left - delta)
        meteor_radial.value = (_meteor_cooldown_left / _meteor_cooldown_max) * 100.0
        meteor_label.text = "%.1fs" % _meteor_cooldown_left
        if _meteor_cooldown_left == 0.0:
            meteor_label.text = "READY"

func _on_gold_changed(team: int, new_amount: int, delta: int) -> void:
    if team == GameManager.Team.PLAYER:
        gold_label.text = "%dg" % new_amount

func _on_base_damaged(team: int, current_hp: int, max_hp: int) -> void:
    if team == GameManager.Team.PLAYER:
        hp_label.text = "%d / %d" % [current_hp, max_hp]
        var target_val: float = (float(current_hp) / float(max_hp)) * 100.0
        hp_bar.value = target_val
        var tween = create_tween()
        tween.tween_property(ghost_hp_bar, "value", target_val, 0.4).set_delay(0.2)

func _on_wave_started(wave_num: int, title: String) -> void:
    wave_title.text = "WAVE %d: %s" % [wave_num, title.to_upper()]
```
