# Spécification d’équilibrage : niveaux, vagues et difficultés

Statut : base d’implémentation pour `WaveManager` et `EconomyManager`.
Portée : 3 niveaux × 3 vagues × 3 difficultés. Les valeurs ci-dessous sont des constantes de design, pas des valeurs déjà validées par simulation. Les critères de sortie demandent une simulation / mesure en jeu avant de déclarer l’équilibrage validé.

## 1. Convention de données et identités

Le niveau est `current_level` (1..3), la vague `current_wave` (1..3). Chaque ligne de composition représente le nombre total d’ennemis à créer pour cette vague, avant multiplicateur de difficulté. Arrondir les comptes avec `roundi(base_count * count_mult)` puis garantir au moins 1 ennemi pour chaque type dont le compte de base est non nul.

Types existants : `enemy_warrior` (Crusader Knight, mêlée), `enemy_archer` (Royal Huntress, distance), `enemy_boss` (Conqueror King, lourd). Utiliser les noms d’affichage suivants dans l’UI : Les Enfers, La Terre, Le Royaume Céleste. Le `WaveManager` actuel utilise THE UNDERWORLD / THE SURFACE / THE CELESTIAL REALM; ces libellés doivent être remplacés ou localisés, sans changer les indices numériques attendus par les sélections de niveau.

## 2. Matrice globale des difficultés

Les multiplicateurs s’appliquent aux unités ennemies à l’instanciation. Ils ne doivent pas muter les `UnitData` partagés : calculer des stats runtime par instance, ou dupliquer les données par instance.

| Difficulté | PV ennemis | Dégâts ennemis | Vitesse ennemie | Intervalle de spawn | Nombre d’ennemis | Or passif joueur |
|---|---:|---:|---:|---:|---:|---:|
| Normal | ×1.00 | ×1.00 | ×1.00 | ×1.00 | ×1.00 | ×1.00 |
| Hard | ×1.25 | ×1.15 | ×1.08 | ×0.88 | ×1.10 | ×0.90 |
| Impossible | ×1.50 | ×1.30 | ×1.15 | ×0.78 | ×1.20 | ×0.80 |

Les récompenses de bounty ennemies suivent le multiplicateur de difficulté × bounty de vague : Normal ×1.00, Hard ×1.05, Impossible ×1.10. Arrondir à l’entier le plus proche, minimum 1. Les coûts des unités du joueur restent inchangés.

## 3. Compositions de référence (Normal)

L’identité tactique augmente du simple nombre vers des unités plus spécialisées. Dans chaque ligne, `W/A/B` = guerriers / archers / boss. Les boss apparaissent seulement à partir de la deuxième vague des niveaux 2 et 3. Les unités de boss ne doivent jamais dépasser 1 par vague.

| Niveau | Vague 1 : W/A/B | Vague 2 : W/A/B | Vague 3 : W/A/B | Total |
|---|---:|---:|---:|---:|
| Les Enfers | 6/1/0 | 7/3/0 | 8/4/0 | 29 |
| La Terre | 7/2/0 | 7/5/1 | 8/6/1 | 37 |
| Le Royaume Céleste | 8/3/0 | 8/6/1 | 9/7/1 | 43 |

Total par vague : Les Enfers 7, 10, 12; La Terre 9, 13, 15; Royaume Céleste 11, 15, 17. Ces comptes remplacent le calcul générique actuel `7 + (level-1)*4 + (wave-1)*3`; cette ancienne formule ne doit pas s’ajouter à la table.

Ordre de spawn : entrelacer les types au lieu de les regrouper, en conservant les proportions à ±1 unité sur chaque moitié de vague. Priorité d’entrelacement : un guerrier, puis un archer si disponible; intercaler le boss au tiers de vague, pas en premier. Ainsi les archers ne sont pas tous neutralisés avant que la mêlée engage.

Identité/pacing :
- Les Enfers : pression de mêlée, archers rares; V1 enseigne, V2 densifie, V3 est un pic sans boss.
- La Terre : composition mixte; les archers forcent une réponse de portée, premier boss télégraphié en V2.
- Le Royaume Céleste : densité et portée élevées, un boss en V2 et V3; V2 est un creux relatif de rythme avant la vague finale.

## 4. Timing des spawns

L’intervalle est le délai entre deux apparitions, non le temps de combat. Chaque vague commence après 2.0 s de télégraphie. Tirer une valeur aléatoire uniforme de ±0.25 s autour de l’intervalle calculé, puis borner le résultat à [1.6, 5.2] s.

| Niveau | Vague 1 | Vague 2 | Vague 3 |
|---|---:|---:|---:|
| Les Enfers | 4.2 s | 3.8 s | 3.4 s |
| La Terre | 4.0 s | 3.6 s | 3.2 s |
| Le Royaume Céleste | 3.8 s | 3.4 s | 3.0 s |

Intervalle final = intervalle de table × multiplicateur difficulté. Le plafonnement de 9 ennemis vivants peut retarder les apparitions : le timer de spawn ne doit pas être remis à zéro tant que le cap est atteint, afin que l’attente ne ralentisse pas artificiellement la reprise. L’IA adaptative peut ajuster l’intervalle de ±10 % maximum autour de cette valeur, sans jamais contourner le cap. Les variations ne doivent pas modifier la composition ou le compte total fixé.

## 5. Économie

Réglage de base : départ joueur 100 or, revenu passif Normal au niveau 1/vague 1 = 3 or/s. Revenu par seconde : `round(base_income * difficulty_income_mult) + (level - 1) + floor((wave - 1) / 2)`, minimum 1. Le facteur de difficulté s’applique seulement à la base 3, pas aux bonus de progression.

Bonus de fin de vague :
- Après une vague 1 ou 2 : `15 + 12 * wave + 5 * level` or.
- Après une vague 3 qui termine le niveau 1 ou 2 : `50 + 15 * level` or.
- La victoire finale ne verse pas de bonus de transition.

Bounty par kill : valeur de `UnitData.gold_bounty` × multiplicateur de difficulté × bonus de niveau, où bonus de niveau vaut 1.00 / 1.05 / 1.10 pour les niveaux 1 / 2 / 3. Arrondir avec `roundi`, minimum 1. Les bounties sont versées uniquement au joueur lorsqu’une unité ennemie meurt. L’or gagné est compté une seule fois dans `GameManager.total_gold_earned`.

Budgets de référence indicatifs pour les bonus de vague, hors passif et kills :
- Niveau 1 : V1 32, V2 44, transition après V3 65, soit 141 or.
- Niveau 2 : V1 37, V2 49, transition après V3 80, soit 166 or.
- Niveau 3 : V1 42, V2 54, aucun bonus final, soit 96 or.

Éviter d’ajouter un bonus de niveau ou difficulté caché dans plusieurs endroits. Le passif et les bonus sont les seules récompenses garanties; les bounties dépendent des kills.

## 6. Durée et survie visées

Définition de la durée d’une vague : du signal `wave_started` au dernier ennemi tué (ou ayant atteint la base). Cible Normal : 45–75 s pour Enfers, 55–85 s pour Terre, 65–95 s pour Royaume Céleste. Hard : 55–90 / 65–100 / 75–115 s. Impossible : 65–105 / 75–120 / 90–135 s.

Cible de survie de base joueur après une campagne complète : Normal 70–85 %, Hard 45–65 %, Impossible 20–40 % lors de simulations automatisées de joueurs de référence. Ce pourcentage signifie proportion des runs terminés avec une base joueur encore vivante, pas proportion d’unités conservées. Viser une différence de réussite d’au moins 15 points entre chaque niveau de difficulté adjacente.

Les taux de survie dépendent de l’IA, du choix des unités et de la qualité du bot : ils ne sont pas déductibles des multiplicateurs seuls. L’acceptation exige des simulations et un rapport de résultats réels, pas l’affirmation que ces objectifs sont déjà atteints.

## 7. Critères d’acceptation mesurables

1. Les 9 couples niveau/vague donnent exactement les comptes W/A/B du tableau en Normal; aucun boss en niveau 1 ou V1; au plus un boss par vague.
2. Avec même graine et même décisions, Hard/Impossible appliquent les multiplicateurs de PV, dégâts, vitesse, intervalle, composition et économie de la matrice. Les stats de données partagées restent intactes après plusieurs spawns.
3. Au moins 500 simulations par difficulté (même distribution de graines et même stratégie de bot) produisent : taux de victoire dans les bandes cibles, et écarts de difficulté adjacentes ≥15 points. Si l’intervalle de confiance Wilson à 95 % chevauche une limite, augmenter à 2 000 runs avant de conclure.
4. Durée médiane par vague dans les intervalles cibles; au moins 80 % des vagues entre 0.7× et 1.4× leur durée cible médiane. Consigner aussi le 10e/90e percentile et le taux de vagues qui atteignent le cap de 9 ennemis vivants.
5. Aucun niveau ne produit un revenu passif inférieur au précédent; le revenu cumulé garanti de fin de niveau est conforme à la table (tolérance 0), hors arrondis explicitement spécifiés. Les coûts et bounties ne changent pas selon l’ordre des appels.
6. Répéter une simulation avec la même graine donne exactement la même séquence de types, d’horodatages de spawn, d’or et de résultat. Injecter un RNG seedé, plutôt que le global RNG, pour permettre ce contrôle.
7. Vérifier via Godot headless : absence d’erreur au chargement, 9 configurations couvertes, comptes d’ennemis exacts, bornes de spawn respectées, aucun soft-lock de vague après le dernier spawn.

## 8. Interface d’implémentation GDScript

Centraliser les données en constantes `LEVEL_WAVES`, `DIFFICULTY`, `SPAWN_INTERVALS` plutôt que des branches arithmétiques éparses. Exposer des helpers purs (ex. `get_wave_composition(level, wave)`, `get_enemy_stat_multiplier(stat)`, `get_wave_spawn_interval(level, wave)`, `get_passive_income_rate(level, wave)`, `get_wave_clear_reward(level, wave)`) pour les tests headless.

La composition donne des nombres absolus. Le scaling de difficulté les multiplie une seule fois. Appliquer PV/dégâts/vitesse à l’instance après initialisation de ses données de base, avant son premier tick de combat. Préciser avec les composants concernés comment l’instance reçoit ces valeurs; ne pas supposer que `WaveManager` peut modifier directement un Resource chargé en commun.

Garder le suivi des vagues et la machine à états de combat existants. Une simulation doit pouvoir appeler les mêmes fonctions de calcul sans créer de scène graphique; séparer les données/calculs purs des appels `Events`/instanciation.
