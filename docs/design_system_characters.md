# Lord of the Dungeon - Design System: Character Assets

## Version
- Date: 2026-11-19
- Plateforme: Godot 4.7.2
- Style: pixel art / 2D, cohérent entre les 3 niveaux

## 1. Unités existantes dans le projet
Trouver les types et niveaux déjà présents.
assets/frames/hero_knight/ (idle/attack/walk/die)
assets/bases/level_{1,2,3}_*.png
Check other folders too.

## 2. Niveaux du jeu
- Niveau 1: The Underworld (hell) - fond rouge/or, enemies hell
- Niveau 2: The Surface (earth) - fond terre/brun, enemies earth
- Niveau 3: The Celestial Realm (sky) - fond bleu/argent, enemies sky

## 3. Assets attendus par niveau
Pour chaque niveau:
- Background (décor, parallax)
- Ennemis (appartenance au niveau)
- Personnages du joueur (class: melee, range, tank)
- Unités neutres (si besoin)

## 4. Design system
### Palette par niveau
Definir les palettes principales et secondaires pour chaque niveau.
### Typographie
Si texte: mettre en page.
### Animations recommandées
- Idle, walk, attack, dead pour chaque unité.
### Résolution
32x32 ou 64x64 px recommandé pour le style actuel (sprites hero_knight 32x32)

## 5. Assets à chercher (sprites, CC0/CC-BY)
Via internet avec license claire (patron CC0/CC-BY).
On ne génère pas d'images avec IA.
### Recherche par niveau
- Niveau 1: hell/crimson/dark fantasy
- Niveau 2: earth/forest/geologic
- Niveau 3: sky/space/celestial

## 6. Structure de répertoire finale
assets/
  characters/        # People/characters (real drawn or free pack)
  creatures/         # Enemies and monsters (if separate)
  backgrounds/       # Level backgrounds
  frames/            # Existing hero animations (keep)

## 7. Liens d'assets libres (à vérifier séparément)
- opengameart.org (CC0/OGA-BY)
- kenney.nl (CC0)
- itch.io (CC0)

## 8. Validation
Tous les fichiers doivent être vérifiés headless dans Godot.
Les chemins à utiliser: res://assets/...
