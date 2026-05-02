# 🚀 PORTAL BLAST — Guide Cursor + Claude Code

> Ce fichier est ton guide principal. Suis les étapes dans l'ordre.

---

## 📦 Ce que contient ce projet

```
PortalBlast/
├── .cursorrules                 ← Contexte auto pour Claude Code
├── .gitignore
├── project.godot                ← Config Godot (prêt)
├── 00_BIBLE_VISUELLE.md         ← Ta charte graphique Broken Folk
├── PROMPT_MAGIQUE.md            ← Génère de nouveaux persos
├── GUIDE_CURSOR.md              ← CE FICHIER
│
├── scripts/
│   ├── autoloads/
│   │   ├── game_manager.gd     ← ✅ FAIT — Score, sauvegarde
│   │   ├── audio_manager.gd    ← ✅ FAIT — Sons et musique
│   │   └── ad_manager.gd       ← ✅ FAIT — Pubs (stubs)
│   ├── characters/
│   │   ├── broken_folk_character.gd  ← ✅ FAIT — Classe parente
│   │   ├── storyteller.gd      ← ✅ FAIT — Le Conteur
│   │   ├── witch.gd            ← ✅ FAIT — La Sorcière
│   │   └── blacksmith.gd       ← ✅ FAIT — Le Forgeron
│   ├── game/                   ← 🔲 À CRÉER avec les prompts
│   ├── ui/                     ← 🔲 À CRÉER avec les prompts
│   └── demo/
│       └── character_demo.gd   ← ✅ FAIT — Démo des persos
│
├── scenes/
│   ├── characters/
│   │   ├── storyteller.tscn    ← ✅ FAIT
│   │   ├── witch.tscn          ← ✅ FAIT
│   │   └── blacksmith.tscn     ← ✅ FAIT
│   ├── components/             ← 🔲 Board, Cell, Piece
│   ├── effects/                ← 🔲 Particules, flash
│   └── demo/
│       └── character_demo.tscn ← ✅ FAIT
│
├── assets/
│   ├── fonts/                  ← 🔲 À télécharger (Google Fonts)
│   ├── sounds/                 ← 🔲 À télécharger (Pixabay)
│   ├── music/                  ← 🔲 À télécharger (Pixabay)
│   └── textures/               ← 🔲 À créer (icône, etc.)
│
└── themes/                     ← 🔲 À CRÉER avec les prompts
```

✅ = Déjà fait, prêt à utiliser
🔲 = À créer avec Claude Code, dans l'ordre des prompts

---

## 🎯 ÉTAPE 1 — Ouvrir le projet (5 min)

### Dans Godot
1. Lance Godot
2. Clique **Import** (pas "New Project")
3. Navigue jusqu'au dossier `PortalBlast/`
4. Sélectionne le fichier `project.godot`
5. Clique **Import & Edit**
6. Le projet s'ouvre dans Godot

### Vérifie que ça marche
1. Dans le panneau FileSystem (en bas à gauche), tu dois voir tous les dossiers
2. Ouvre `scenes/demo/character_demo.tscn`
3. Appuie sur **F6** → tes 3 persos Broken Folk doivent apparaître
4. Si ça marche → ✅ tu es prêt

### Si ça plante
- Erreur "Script not found" → vérifie que les fichiers .gd sont bien dans scripts/
- Erreur "Autoload" → va dans Project > Project Settings > Autoload et vérifie les 3 chemins

---

## 🎯 ÉTAPE 2 — Ouvrir dans Cursor (2 min)

1. Ouvre **Cursor**
2. **File → Open Folder** → sélectionne le dossier `PortalBlast/`
3. Tu vois toute l'arborescence à gauche
4. Le fichier `.cursorrules` donne automatiquement le contexte à Claude Code
5. Ouvre le chat Claude Code dans Cursor (Ctrl+L ou Cmd+L)

---

## 🎯 ÉTAPE 3 — Les prompts dans l'ordre

Copie-colle ces prompts UN PAR UN dans Claude Code (Cursor).
Après chaque prompt, teste dans Godot (F5 ou F6).

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 1 — Thème UI Broken Folk
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée le thème UI global du jeu Portal Blast dans le style "Broken Folk".

Crée le fichier themes/broken_folk_theme.tres (Theme resource Godot 4).

Utilise UNIQUEMENT la palette Broken Folk définie dans .cursorrules :
- Fond : PARCHMENT #f4ead5
- Texte : OLD_INK #3a2818
- Accent : GOLD_DUST #d4af37
- Boutons : fond MOSS_GREEN #7a8b3d, texte BONE_WHITE #f0e8d0
- Panels : fond PARCHMENT avec bordure OLD_INK fine

Configure les StyleBoxFlat pour :
- Button (normal/hover/pressed) : coins arrondis 8px, bordure OLD_INK 2px
- Panel : fond parchemin semi-transparent
- Label : couleur OLD_INK par défaut

Crée aussi scripts/ui/animated_button.gd :
- Scale 1.0 → 0.93 sur press, bounce 1.05 → 1.0 sur release
- Tween de 0.15s

Mets à jour project.godot pour appliquer le thème global :
[gui]
theme/custom="res://themes/broken_folk_theme.tres"

Tout commenté en français.
```

✅ **Test** : Ouvre n'importe quelle scène, les boutons doivent avoir le style parchemin.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 2 — La grille et les cases
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée le système de grille 8x8 pour Portal Blast (style Block Blast).

1. scripts/game/cell.gd + scenes/components/cell.tscn :
   - Une case individuelle de la grille
   - Propriétés : is_filled (bool), block_color (Color), block_symbol (String)
   - Visuel : Polygon2D carré avec coins arrondis, contour OLD_INK #3a2818
   - Quand remplie : affiche la couleur + un petit symbole au centre
   - Symboles possibles : "✦" "◆" "●" "▲" "♦" "★" (style Broken Folk)
   - Méthodes : set_filled(color, symbol), clear_cell(), clear_with_animation()
   - Animation clear : scale → 0 + rotation 90°, durée 0.4s

2. scripts/game/board.gd + scenes/components/board.tscn :
   - GridContainer 8 colonnes de Cell instances
   - Variable : cells Array de 8x8
   - Méthodes :
     * can_place_piece(shape, row, col) → bool
     * place_piece(shape, color, symbol, row, col)
     * check_and_clear_lines() → {cleared: int, positions: Array}
     * is_game_over(pieces: Array) → bool
     * show_ghost(shape, row, col, color) — aperçu semi-transparent
     * clear_ghost()
   - Signaux : piece_placed, lines_cleared(count, positions)
   - Bordure : Rectangle OLD_INK autour de la grille, coins arrondis

   COULEURS DES BLOCS (palette Broken Folk) :
   - RUST_RED #c4615e + symbole "✦"
   - MOSS_GREEN #7a8b3d + symbole "◆"
   - EGGPLANT #7a4878 + symbole "●"
   - STORM_BLUE #3a4878 + symbole "▲"
   - COPPER #a55838 + symbole "♦"
   - GOLD_DUST #d4af37 + symbole "★"

Contraintes : GDScript, Godot 4, commenté en français.
La grille doit être centrée horizontalement, occuper ~75% de la largeur.
```

✅ **Test** : Crée une scène temporaire qui instancie board.tscn pour voir la grille.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 3 — Les pièces et le spawner
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée le système de pièces pour Portal Blast.

1. scripts/game/shapes_data.gd (Resource ou const) :
   20 formes possibles définies comme Array2D :
   - 1x1, 2x1, 1x2, 3x1, 1x3, 4x1, 1x4, 5x1, 1x5
   - 2x2, 3x3
   - L (4 rotations), T, S, Z, croix (+)

2. scripts/game/piece.gd + scenes/components/piece.tscn :
   - Affiche la pièce en assemblant des mini-cells
   - Propriétés : shape (Array2D), color (Color), symbol (String)
   - Taille des mini-cells : proportionnelle (plus petites que les cells du board)
   - Visuel : même style que les cells mais en miniature
   - Pas de drag & drop encore (on le fait au prompt suivant)
   - Animation idle : léger pulse (scale 1.0 → 1.02 → 1.0)

3. scripts/game/piece_spawner.gd + scenes/components/piece_spawner.tscn :
   - HBoxContainer avec 3 emplacements
   - Méthodes : spawn_new_pieces(), remove_piece(index), all_used() → bool
   - Génère 3 pièces aléatoires (forme + couleur/symbole Broken Folk)
   - Signal : pieces_exhausted (quand les 3 sont placées)
   - Animation d'apparition : scale 0 → 1 avec bounce

Contraintes : GDScript, Godot 4, commenté en français.
```

✅ **Test** : Instancie le spawner pour voir 3 pièces s'afficher.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 4 — Drag & Drop tactile
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Ajoute le drag & drop tactile sur les pièces de Portal Blast.

Comportement :
1. APPUI sur une pièce → scale 1.15, glow, état dragging = true
2. GLISSE le doigt → la pièce suit avec offset -150px vers le haut 
   (pour que le joueur voie où il pose), le board affiche un ghost 
   (aperçu fantôme semi-transparent)
3. RELÂCHE → si position valide : place la pièce + efface de la liste.
   Si invalide : la pièce revient à sa position (tween 0.2s)

Modifie :
1. piece.gd : gestion InputEventScreenTouch + InputEventScreenDrag
   Signaux : drag_started(piece), drag_updated(piece, world_pos), 
   drag_ended(piece, world_pos)

2. board.gd : méthodes world_to_grid(pos), handle_drag_update(), 
   handle_drag_end()

3. piece_spawner.gd : connecte les signaux des pièces au board

4. Crée scenes/game.tscn + scripts/game/game.gd qui contient :
   - Background ColorRect couleur PARCHMENT #f4ead5
   - Header : score (gauche) + record (droite), style Broken Folk
   - Board (centré)
   - PieceSpawner (en bas)
   - Bouton pause ⏸ (haut droite)
   - Orchestration : quand 3 pièces placées → respawn
   - Quand game over détecté → émettre signal

Contraintes : GDScript, Godot 4, tactile uniquement, commenté en français.
```

✅ **Test** : Lance game.tscn, tu dois pouvoir drag & drop les pièces sur la grille.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 5 — Score, combos, effets satisfaisants
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Ajoute le système de score et les effets visuels satisfaisants.

1. SCORE (dans game.gd, connecté à GameManager) :
   - Chaque bloc placé = +1
   - Ligne effacée = +10 × multiplicateur combo
   - Combo 2 lignes = x2, 3 = x3, 4+ = x5
   - Streak bonus : +5 par streak > 2

2. POPUPS DE COMBO (scripts/ui/combo_popup.gd + scène) :
   - Textes aléatoires style Broken Folk :
     "LEGENDARY!", "ANCIENT POWER!", "FOLK MAGIC!", "GOLDEN!", 
     "MASTERCRAFT!", "ENCHANTED!"
   - Apparaît au centre, scale 0.3 → 1.3 → 1.0 puis fade
   - Couleur GOLD_DUST #d4af37
   - Sub-label "COMBO ×N" en OLD_INK

3. PARTICULES D'EFFACEMENT (scripts/game/particle_burst.gd) :
   - Quand une cellule est effacée, spawn des étoiles dorées
   - 5-8 particules par cellule, direction aléatoire
   - Couleur GOLD_DUST + la couleur du bloc
   - Auto-destruction après 0.6s

4. SCREEN SHAKE (scripts/game/screen_shake.gd) :
   - shake(intensity, duration) sur le nœud parent
   - Déclenché sur combo >= 2

5. FLASH BLANC léger (0.05s in, 0.15s out) à chaque clear

6. SCORE LABEL ANIMÉ (scripts/ui/score_label.gd) :
   - Compteur qui monte progressivement (tween)
   - Pulse scale quand ça change
   - Couleur GOLD_DUST si nouveau record

Contraintes : GDScript, Godot 4, style Broken Folk, commenté en français.
```

✅ **Test** : Joue, efface des lignes → les effets doivent être SATISFAISANTS.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 6 — Menu principal avec Le Conteur
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée le menu principal de Portal Blast, style Broken Folk.

scenes/main_menu.tscn + scripts/ui/main_menu.gd :

1. Background : ColorRect PARCHMENT #f4ead5

2. Le Conteur (storyteller.tscn) : 
   - Placé à gauche, scale 1.8
   - Il respire et cligne des yeux (automatique)

3. Titre "PORTAL BLAST" :
   - "PORTAL" en OLD_INK #3a2818, grande taille
   - "BLAST" en GOLD_DUST #d4af37, encore plus grand
   - Léger pulse scale en idle

4. Tagline "✦ Puzzle des Anciens ✦" en OLD_INK, petit

5. High Score affiché si > 0 : "★ Record : {score}"

6. Bouton PLAY : "✦ COMMENCER ✦"
   - Style Broken Folk (fond MOSS_GREEN, texte BONE_WHITE)
   - Animation bounce au press
   - Au tap → transition vers game.tscn

7. Bouton Son ON/OFF (petit, haut droite)

8. Espace bannière pub en bas (placeholder)

9. Animations au _ready : fade-in séquentiel de chaque élément

Mets à jour project.godot : main_scene = main_menu.tscn

Contraintes : GDScript, Godot 4, commenté en français.
```

✅ **Test** : Lance le projet (F5) → le menu s'affiche avec Le Conteur.

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 7 — Game Over avec La Sorcière
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée l'écran Game Over de Portal Blast.

scenes/game_over.tscn + scripts/ui/game_over.gd :

1. Background : dégradé PARCHMENT → LEATHER (plus sombre)

2. La Sorcière (witch.tscn) :
   - Placée à droite, scale 1.5
   - reaction_surprised() au _ready
   - Si nouveau record → reaction_victory()

3. Titre "FIN DU CONTE" en OLD_INK, grand

4. Si nouveau record : "★ NOUVEAU RECORD ★" en GOLD_DUST, pulse

5. Carte de score (Panel style parchemin) :
   - Score final (compteur animé de 0 au score)
   - Record : {high_score}
   - Lignes : {total_lines_cleared}

6. Bouton "🧪 Continuer (Potion magique)" :
   - Style EGGPLANT
   - Au tap → AdManager.show_rewarded() → si succès, efface 3 lignes, 
     retourne au jeu

7. Bouton "✦ RECOMMENCER ✦" :
   - Style MOSS_GREEN, gros
   - Au tap → AdManager.show_interstitial_smart() puis nouvelle partie

8. Bouton "🏠 Retour" : petit, outline

Contraintes : GDScript, Godot 4, commenté en français.
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 8 — Menu Pause
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Crée le menu pause de Portal Blast.

scenes/pause_menu.tscn + scripts/ui/pause_menu.gd :
- CanvasLayer overlay semi-transparent (PARCHMENT avec alpha 0.85)
- Panel central style parchemin avec :
  * "PAUSE" en OLD_INK
  * Bouton "▶ Reprendre"
  * Bouton "🔄 Recommencer"
  * Bouton "🏠 Menu"
  * Toggle son ON/OFF
- get_tree().paused = true au _ready
- Fade-in 0.3s à l'ouverture

Dans game.tscn, le bouton ⏸ instancie pause_menu.tscn.

Contraintes : GDScript, Godot 4, commenté en français.
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PROMPT 9 — Polish et corrections
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
Fais une passe de polish sur Portal Blast.

1. Vérifie tous les chemins de scènes (menu→jeu→pause→menu, 
   menu→jeu→game over→rejouer, etc.)

2. Vérifie que les autoloads fonctionnent (GameManager.score, etc.)

3. Performance : limite les tweens simultanés, pool les particules

4. Accessibilité : boutons minimum 44x44, contraste suffisant

5. Sauvegarde : vérifie que le high score persiste entre les sessions

6. Splash screen simple (1s) : fond PARCHMENT + titre qui fade in, 
   puis transition vers main_menu

7. Configure l'export Android dans project.godot :
   - Package : com.brokenfolk.portalblast
   - Min SDK : 21, Target SDK : 34
   - Permissions : INTERNET, ACCESS_NETWORK_STATE

Contraintes : GDScript, Godot 4, commenté en français.
```

---

## 📋 RÉCAP — Dans quel ordre tout faire

```
AUJOURD'HUI (30 min)
━━━━━━━━━━━━━━━━━━━
□ Ouvre le projet dans Godot → vérifie que la démo marche (F6)
□ Ouvre le dossier dans Cursor

JOUR 1 (2-3h)
━━━━━━━━━━━━━━━━━━━
□ PROMPT 1 — Thème UI
□ PROMPT 2 — Grille + cases
□ Teste dans Godot

JOUR 2 (2-3h)
━━━━━━━━━━━━━━━━━━━
□ PROMPT 3 — Pièces + spawner
□ PROMPT 4 — Drag & drop
□ Teste dans Godot (tu peux JOUER !)

JOUR 3 (2-3h)
━━━━━━━━━━━━━━━━━━━
□ PROMPT 5 — Score + effets satisfaisants
□ PROMPT 6 — Menu principal
□ Teste dans Godot

JOUR 4 (2h)
━━━━━━━━━━━━━━━━━━━
□ PROMPT 7 — Game Over
□ PROMPT 8 — Pause
□ PROMPT 9 — Polish

JOUR 5+ (variable)
━━━━━━━━━━━━━━━━━━━
□ Télécharge les polices (Google Fonts : Grenze Gotisch + Nunito)
□ Télécharge les sons (Pixabay)
□ Crée l'icône (Canva)
□ Publie sur le Play Store
```

---

## 🆘 Si un prompt plante

```
1. Copie l'erreur EXACTE de Godot
2. Dis à Claude Code dans Cursor :
   "J'ai cette erreur dans Godot : [COLLE L'ERREUR]. 
   Corrige le fichier concerné."
3. Si toujours pas → "Donne-moi le fichier [nom] COMPLET 
   en repartant de zéro."
```

---

## 🎨 Pour créer de nouveaux persos

Utilise le fichier **PROMPT_MAGIQUE.md** dans ce projet. Copie le prompt, 
remplace les crochets, colle dans Cursor.

---

## 💡 Astuces Cursor + Claude Code

1. **Le .cursorrules** donne automatiquement le contexte à Claude Code. 
   Tu n'as PAS besoin de re-expliquer le projet à chaque prompt.

2. **Si Claude Code te demande quel langage** → dis "GDScript, Godot 4"

3. **Si le code est trop long** → demande fichier par fichier :
   "Génère seulement board.gd pour l'instant"

4. **Pour modifier un truc précis** → sois chirurgical :
   "Dans board.gd, change la grille de 8x8 à 10x10"

5. **Ctrl+K** dans Cursor pour éditer un fichier spécifique avec Claude

---

*Bon code ! Les Contes Brisés n'attendent que toi. ✦*
