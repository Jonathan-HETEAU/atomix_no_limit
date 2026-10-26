# Atomix NoLimit — version Haxe / Heaps

Portage du jeu Java (`../src`) sur [Heaps](https://heaps.io) : même génération de niveaux, mêmes
règles, mêmes trois vues (menu, plateau, molécule) et mêmes contrôles à la souris. Le jeu tourne
dans un navigateur (WebGL) et en natif avec HashLink.

<img src="screenshot.png" alt="Niveau 59" width="480"/>

## Contrôles

| Où | Action |
|---|---|
| Plateau | clic gauche sur un atome : le sélectionne, des flèches montrent où il peut aller ; clic sur une flèche : l'atome glisse jusqu'au premier obstacle |
| Plateau | glisser avec le bouton droit : déplace le plateau ; molette : zoom ; clic droit : vue molécule |
| Plateau | boutons du haut : annuler le dernier coup, recommencer le niveau ; coins : menu (gauche), molécule (droite) |
| Molécule | glisser : déplace ; molette : zoom ; clic droit ou coin droit : retour au plateau |
| Menu | Continuer (retour à la vue précédente), Recommencer (la campagne repart du niveau 1), Quitter (HashLink seulement) |

## Construire et lancer

| Commande | Résultat |
|---|---|
| `haxe build-js.hxml` | `bin/game.js` : servir le dossier (`npx http-server -c-1 .`) et ouvrir `index.html` |
| `haxe build-hl.hxml` | `bin/game.hl` : `hl bin/game.hl` depuis ce dossier |
| `haxe test.hxml` | tests des règles (`test/TestModel.hx`), sans fenêtre : génère ~300 niveaux et vérifie que chacun se résout |
| `python3 tools/make_font.py` | régénère la police bitmap `res/font/bold.*` (DejaVu Sans Bold, la police « Dialog » de Java) |

Ajouter `-debug` au build web expose le jeu à la page (`window.game`) pour les tests en
navigateur headless (skill `heaps-browser-test`).

Versions utilisées : Haxe 4.3.7, Heaps git `ec332019` (octobre 2026), format git ; pour
HashLink, HashLink git (SDL3) avec `haxelib dev hlsdl <hashlink>/libs/sdl` (voir le skill
`heaps-setup`).

## Organisation

| Fichier | Rôle | Équivalent Java |
|---|---|---|
| `src/model/Generator.hx` | génération d'un niveau : carte en blocs 5x5, molécule, puzzle par coups joués à l'envers | `AtomixGenerateur` |
| `src/model/Level.hx` | un niveau (sol, molécule, atomes de départ), difficulté par numéro, sérialisation | `AtomixNiveau` |
| `src/model/Game.hx` | la partie : glissement des atomes, annulation, détection de la molécule | `AtomixPartie` |
| `src/model/Campaign.hx` | la campagne sans fin : niveau suivant, reprise d'une sauvegarde | `AtomixCampagneNoLimit`, `AtomixJoueur` |
| `src/model/Rng.hx` | générateur aléatoire à graine (mêmes niveaux sur toutes les cibles) | `java.util.Random` |
| `src/Progress.hx` | sauvegarde (`hxd.Save` : `atomix.sav` ou `localStorage`) | `AtomixFile`, `AtomixSauvegarde` |
| `src/Main.hx` | l'application : les trois vues et le passage de l'une à l'autre | `AtomixControleur`, `AtomixVue` |
| `src/screen/` | `MenuScreen`, `GameScreen`, `MoleculeScreen` | `AtomixMenuVue`, `AtomixPartieVue` + `AtomixPartieControleur`, `AtomixMoleculeVue` |
| `src/view/Painter.hx` | dessin des atomes, boutons, flèches, numéro de niveau | `AtomixPainter` |
| `src/view/Color.hx`, `Camera.hx`, `IconButton.hx` | couleurs (`brighter`/`darker` de `java.awt.Color`), caméra, boutons ronds | `Color`, `AtomixCamera`, les `mRectangle` |

Le modèle (`src/model/`) n'utilise pas Heaps : il est testé avec `--interp`.

## Différences avec la version Java

Corrections et ajouts minimes faits pendant le portage :

- La partie en cours est sauvegardée à chaque coup (le niveau et ses coups) : on reprend où on en
  était. En Java la sauvegarde des coups était prévue mais vide (`SauvegardeUpdate`), seul le
  niveau était gardé.
- Le générateur ne plante plus quand la molécule est emmurée (la molécule est alors plus petite).
- Un clic juste à gauche ou au-dessus du plateau ne sélectionne plus la case 0 (division entière
  arrondie vers zéro en Java), et un clic sur un bouton ne sélectionne pas l'atome dessous.
- Le bouton « Quitter » n'existe pas dans la version web (une page ne peut pas se fermer).
