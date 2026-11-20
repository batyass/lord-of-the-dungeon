extends Node

var passed: int = 0
var failed: int = 0

func check(cond: bool, msg: String) -> void:
    if cond:
        passed += 1
        print("PASS: " + msg)
    else:
        failed += 1
        print("FAIL: " + msg)

func _ready():
    print("--- Assets Test ---")

    # Les packs de personnages existants (CC0)
    var res_paths = [
        "res://assets/sprites/hero-knight/Hero Knight/Sprites/Idle.png",
        "res://assets/sprites/huntress/Huntress/Sprites/Idle.png",
        "res://assets/sprites/evil-wizard/Evil Wizard/Sprites/Idle.png",
        "res://assets/sprites/fire-worm/Fire Worm/Sprites/Worm/Idle.png",
        "res://assets/bases/level_1_hell_left_base.png",
        "res://assets/bases/level_2_earth_left_base.png",
        "res://assets/bases/level_3_sky_right_base.png",
        "res://assets/backgrounds/level_1_hell.png",
        "res://assets/backgrounds/level_2_earth.png",
        "res://assets/backgrounds/level_3_sky.png",
    ]

    for path in res_paths:
        var res := load(path)
        check(res != null, "Chargement: " + path)

    # Les characters existants dans le projet
    var char_paths = [
        "res://assets/sprites/units/hero_knight/idle.png",
        "res://assets/sprites/units/huntress/idle.png",
        "res://assets/sprites/units/skeleton/idle.png",
        "res://assets/sprites/units/king/idle.png",
        "res://assets/sprites/units/fire_worm/idle.png",
        "res://assets/sprites/units/flying_eye/flight.png",
        "res://assets/sprites/units/flying_eye/attack.png",
        "res://assets/sprites/units/flying_eye/death.png",
        "res://assets/sprites/units/flying_eye/take_hit.png",
    ]
    for path in char_paths:
        var res := load(path)
        check(res != null, "Characters existant: " + path)

    print("--- Assets: %d passed, %d failed ---" % [passed, failed])

    if failed > 0:
        get_tree().quit(1)
    else:
        get_tree().quit(0)
