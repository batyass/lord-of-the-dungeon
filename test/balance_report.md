# Headless Balance Simulation Report

Generated automatically via `test/simulate_balance.gd` on Godot 4.7.2.

## Summary of 9 Level x Difficulty Configurations

| Level | Difficulty | Runs | Win Rate | Waves | Avg Battle (s) | Avg Wave (s) | Gold Earned | Residual Gold | Meteor Dmg (Reg/Boss) | Meteor CD | Meteor Casts | Player Spw/Lost | Enemy Spw/Killed | Softlocks |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | normal | 20 | 100% | 180 | 517.1 | 57.5 | 5659.1 | 91.7 | 90 / 95 | 22.0s | 20.7 | 97 / 17 | 174 / 174 | 0 |
| 1 | hard | 20 | 55% | 99 | 312.0 | 57.6 | 3288.8 | 42.3 | 99 / 109 | 25.0s | 11.6 | 62 / 15 | 105 / 103 | 0 |
| 1 | impossible | 20 | 25% | 56 | 204.7 | 60.1 | 1849.3 | 21.6 | 108 / 124 | 28.0s | 6.8 | 42 / 16 | 62 / 56 | 0 |
| 2 | normal | 20 | 100% | 120 | 347.9 | 58.0 | 4187.6 | 85.3 | 120 / 110 | 24.0s | 13.1 | 74 / 15 | 127 / 127 | 0 |
| 2 | hard | 20 | 70% | 90 | 285.8 | 59.6 | 3292.5 | 52.3 | 132 / 126 | 27.0s | 10.1 | 68 / 26 | 103 / 101 | 0 |
| 2 | impossible | 20 | 20% | 29 | 138.5 | 62.4 | 1321.1 | 23.2 | 144 / 143 | 30.0s | 4.5 | 35 / 18 | 43 / 37 | 0 |
| 3 | normal | 20 | 80% | 50 | 161.5 | 60.1 | 1915.8 | 78.8 | 150 / 125 | 26.0s | 6.2 | 46 / 20 | 60 / 58 | 0 |
| 3 | hard | 20 | 80% | 50 | 160.7 | 60.1 | 1931.2 | 41.2 | 165 / 144 | 29.0s | 5.5 | 45 / 19 | 63 / 61 | 0 |
| 3 | impossible | 20 | 25% | 28 | 134.1 | 67.7 | 1340.1 | 20.1 | 180 / 163 | 32.0s | 4.3 | 39 / 24 | 45 / 39 | 0 |

## Win Rates and Metrics by Difficulty Mode

| Difficulty | Runs | Wins | Losses | Win Rate | Target Range | Status | Avg Battle (s) | Avg Wave (s) | Avg Gold Earned | Avg Residual Gold |
|---|---|---|---|---|---|---|---|---|---|---|
| Normal | 60 | 56 | 4 | 93.3% | 85-95% | **PASS** | 342.2 | 58.0 | 3920.8 | 85.3 |
| Hard | 60 | 41 | 19 | 68.3% | 60-75% | **PASS** | 252.9 | 58.9 | 2837.5 | 45.3 |
| Impossible | 60 | 14 | 46 | 23.3% | 15-30% | **PASS** | 159.1 | 62.6 | 1503.5 | 21.6 |

## Difficulty Metrics & Calibrations

| Difficulty | Health Mult | Damage Mult | Speed Mult | Spawn Interval | Wave Count Mult | Income Rate | Kill Bounty | Clear Reward |
|---|---|---|---|---|---|---|---|---|
| Normal | 1.650x | 1.570x | 1.155x | 0.588x | 1.310x | 0.695x | 0.715x | 0.715x |
| Hard | 1.685x | 1.630x | 1.180x | 0.565x | 1.350x | 0.650x | 0.700x | 0.700x |
| Impossible | 1.680x | 1.600x | 1.180x | 0.600x | 1.320x | 0.650x | 0.700x | 0.700x |

## Verdict

- Status: **PASS**
- All 9 combinations (Level 1..3 x Normal/Hard/Impossible) simulated cleanly and terminated within allowed time bounds.
- Softlocks detected: **0**
- Stuck campaigns: **0**
- Special Attack (Meteor) dynamic scaling successfully validated across all levels and difficulties.

## Simulation Details

- **Special Attack (Meteor)**: Dynamic scaling calibrated via `WaveManager.get_meteor_damage` and `WaveManager.get_meteor_cooldown`.
  - Level 1: Regular 90-108 dmg, Boss 95-124 dmg, Cooldown 22s-28s.
  - Level 2: Regular 120-144 dmg, Boss 110-143 dmg, Cooldown 24s-30s.
  - Level 3: Regular 150-180 dmg, Boss 125-163 dmg, Cooldown 26s-32s.
- **Combat & Lane Clash**: Data-driven unit combat stats loaded directly from `.tres` resources (Golem, Skeleton, Bat vs Crusader Knight, Archer, King Boss).
- **Human Reaction & Decision Modeling**: Bot models realistic perception delays (0.45s min reaction after unit affordability; 1.2s-2.2s wave start delay), unit spawn cooldown checks, input pacing (0.35s-0.65s), decision intervals (0.35s-1.2s), tactical defense / saving strategies, and 0.5s-1.2s reaction delay before Special Attack (Meteor) triggers.
- **Wave Progression & Difficulty Scaling**: Driven by `WaveManager` composition matrices and stat multipliers.
- **Economy**: Passive base rate (3.0g/s scaled by difficulty income multiplier) plus wave clear rewards.
