# Lord of the Dungeon - Design System: Character Assets
# Spec de l'unité et des assets visuels pour les 3 niveaux

## 1. Vision par niveau (palette & Être)

### Niveau 1 — The Underworld (Enfer)
Thème : infernal, rouge/or, combustible
Palette dominante :
  - fond : #1A0508 (terrible)
  - charnage : #E03030 (crimson)
  - or : #FFB703
  - lueur : #FF4500 (orange rouge)
  - de combat : #8B0000 (noir de bois)
  - saturé : rouge profond, flammes

### Niveau 2 — The Surface (Terre)
Thème : terre, froid, minéral
Palette dominante :
  - fond : #12141A (gris-brun)
  - verdure : #34564A (sapin)
  - or : #D4AF37 (or de la lune)
  - sable : #C8A96E (sable)
  - pierre : #4A4038 (grès)
  - sec : beige clair

### Niveau 3 — The Celestial Realm (Ciel)
Thème : céleste, bleu/argent, aube
Palette dominante :
  - fond : #0A0E1A (nuage nuit)
  - bleu ciel : #3E7CB1 (azur)
  - argent : #C0C0C0 (pierre)
  - lueur : #7B68EE (indigo)
  - étoile : #FFFFFF
  - melon : #FF7F50 (cobalt)

## 2. Charte graphique du personnage

### Unité de base
- Type : personnage 2D, anime (idles, attaque, marche, mort)
- Résolution cible : 32x32 px (sprites 16x16/32x32)
- Style : pixel art / épuré, transparence au centre
- Forme : silhouète simple, épaisseur constante, couleurs distinctes entre les 3 équipes

### Alignement couleurs
- Joueur : bienséances violettes/bleu (nouvelle domination)
- Ennemi (Niveau 1) : or/argent (Enfer)
- Ennemi (Niveau 2) : rouge/or (Terre)
- Ennemi (Niveau 3) : bleu/argent (Ciel)

### Composants visuels
1. Silhouette
2. Vêtements / armure
3. Armes
4. Élément magique / glow
5. Effet de focus ou d'ataque (si nécessaire)
6. État :"vive", "blessé", "mort"

## 3. Structure de répertoire (res://assets/characters/)

res://assets/characters/
├── level_1_hell/                     # Enfer
│   ├── player/                      # Joueur
│   │   ├── idle.png
│   │   ├── attack.png
│   │   ├── walk.png
│   │   └── dead.png
│   ├── enemy/                       # Ennemi (Infernaux)
│   │   ├── idle.png
│   │   ├── attack.png
│   │   ├── walk.png
│   │   └── dead.png
│   └── unit/                        # Unités (buveurs, archers, etc.)
│       └── ...
├── level_2_earth/                   # Terre
│   ├── player/
│   ├── enemy/
│   └── unit/
└── level_3_sky/                     # Ciel
    ├── player/
    ├── enemy/
    └── unit/

## 4. Calques de l'asset de personnage

Un personnage s'assemble en plusieurs couches :
1. Background / fond
2. Corps / silhouette
3. Vêtement / armure
4. Armes
5. Éléments magiques / glow
6. État : vie, blessure, mort

## 5. État des unités

- Idle (attente)
- Walk (marche)
- Attack (attaque)
- Dead (mort)
- Hit (blessé)

## 6. Palette couleur par niveau

### Niveau 1 — The Underworld
- Rond de feu : #FF4500
- Couleur du projet : #E03030
- Fond : #1A0508
- Or : #FFB703

### Niveau 2 — The Surface
- Rond de feu : #8B4513 (boulet de fer)
- Couleur du projet : #34564A (vert sacré)
- Fond : #12141A
- Or : #D4AF37

### Niveau 3 — The Celestial Realm
- Rond de feu : #4169E1 (bleu royal)
- Couleur du projet : #3E7CB1
- Fond : #0A0E1A
- Argent : #C0C0C0

## 7. Ressources audio suggérées

Aucune audio n'est exigée pour ce ticket, mais une fois les sprites intégrés,
il faudra en ajouter pour l'attaque, la mort et le pas (vox/effets cloche etc.)

## 8. License

Tous les assets doivent être sous :
- CC0 (public domain) ou
- CC-BY (croit minimal)

Licence à afficher dans le README du projet.

## 9. Validation

Aucune image n'est générée localement, elle sera déposée par la squad.
Les chemins ne doivent pas être touchés.
Les assets seront chargés via `load("res://assets/characters/...")` puis vérifiés headless.
