# 🪄 PROMPT MAGIQUE — Génère un nouveau perso Broken Folk

> Copie-colle ce prompt dans Claude Code (Cursor) à chaque fois que tu veux 
> ajouter un nouveau personnage à ta marque. Remplace juste les `[CROCHETS]`.

---

## 🎯 Le prompt à copier-coller

```
Tu es expert Godot 4 GDScript. Crée-moi un nouveau personnage pour ma 
marque "Broken Folk".

NOM DU PERSO : [NOM, ex: "Le Voyageur"]
MÉTIER/RÔLE : [DESCRIPTION COURTE, ex: "voyageur avec sac à dos et bâton"]
COULEUR DOMINANTE : [CHOISIS UNE COULEUR DE LA PALETTE]

═══════════════════════════════════════
RÈGLES DE MARQUE À RESPECTER (NON-NÉGOCIABLES) :
═══════════════════════════════════════

1. PALETTE OFFICIELLE (utilise UNIQUEMENT ces couleurs) :
   - PARCHMENT #f4ead5 (fond)
   - OLD_INK #3a2818 (contours, JAMAIS noir pur)
   - LEATHER #5a3818
   - RUST_RED #c4615e
   - MOSS_GREEN #7a8b3d
   - EGGPLANT #7a4878
   - STORM_BLUE #3a4878
   - COPPER #a55838
   - SKIN_WARM #e8c8a4 (peau)
   - BONE_WHITE #f0e8d0
   - GOLD_DUST #d4af37 (touches magiques)

2. RÈGLES OBLIGATOIRES :
   - 3 asymétries volontaires minimum (yeux différents, bras 
     différents, accessoire penché)
   - Lignes pas parfaitement droites (style fait main)
   - Métier/rôle visible (objet ou vêtement caractéristique)
   - Yeux désaxés (pupilles regardent de côté)
   - Expression "âme songeuse" (pas grand sourire, regard calme)
   - 3-5 étoiles dorées seront ajoutées automatiquement par la 
     classe parente

3. CONTRAINTES TECHNIQUES :
   - Hérite de BrokenFolkCharacter (classe parente déjà créée)
   - Format Godot 4, GDScript uniquement
   - Polygon2D natif (pas d'image bitmap)
   - Contours avec Line2D, width = 2.5 px pour le principal
   - Résolution : ~200×280 px de référence
   - Origine du perso au centre du corps (Vector2(0, 0))

═══════════════════════════════════════
LIVRABLES ATTENDUS :
═══════════════════════════════════════

1. **scripts/characters/[nom_perso].gd** :
   ```
   extends BrokenFolkCharacter
   class_name [NomClasse]
   
   func _ready_character() -> void:
       primary_color = [COULEUR_DOMINANTE]
       secondary_color = [COULEUR_SECONDAIRE]
       eye_color = [COULEUR_YEUX]
       star_count = [3 ou 4 ou 5]
   
   func _process_character(_delta: float) -> void:
       # Animation custom du perso (balancement, etc.)
       var sway = sin(idle_time * [VITESSE]) * [INTENSITÉ]
       rotation = sway
   ```

2. **scenes/characters/[nom_perso].tscn** :
   - Un Node2D racine avec le script attaché
   - Un sous-Node2D "Body" contenant : jambes, vêtement principal, 
     accessoires (objet du métier), bras
   - Un sous-Node2D "Head" contenant : visage, cheveux/chapeau, yeux 
     (LeftEyeWhite, RightEyeWhite avec asymétrie), pupilles, paupières 
     cachées (LeftEyelid, RightEyelid), sourcils, nez, bouche, joues
   - Format texte .tscn de Godot 4
   - IMPORTANT : nomme bien les nœuds "LeftEyelid", "RightEyelid", 
     "LeftEyeWhite", "RightEyeWhite" pour que les animations héritées 
     fonctionnent

3. Pour intégrer dans la scène de démo, ajoute juste :
   ```
   [node name="[NomPerso]" parent="." instance=ExtResource("X_perso")]
   position = Vector2(X, Y)
   scale = Vector2(1.4, 1.4)
   ```

═══════════════════════════════════════
EXEMPLES DE PERSOS POSSIBLES :
═══════════════════════════════════════

- Le Voyageur (Storm Blue, sac à dos + bâton)
- L'Apothicaire (Rust Red, lunettes rondes + fioles)
- L'Astronome (Old Ink + Gold, robe étoilée + télescope)
- La Cartographe (Leather + Copper, parchemin + plume)
- Le Bouffon (palette mixte, chapeau à clochettes)
- La Druidesse (Moss Green, couronne de feuilles + bâton)
- Le Marchand (Gold Dust, cape rouge + sac de pièces)
- La Fileuse (Eggplant, quenouille + fil doré)
- Le Bibliothécaire (Storm Blue, livre énorme + lunettes)
- L'Herboriste (Moss Green, panier de plantes)

═══════════════════════════════════════
VALIDATION FINALE :
═══════════════════════════════════════

Avant de me donner le code, vérifie ta CHECKLIST :
- [ ] Au moins 3 asymétries volontaires ?
- [ ] Couleurs uniquement de la palette officielle ?
- [ ] Métier/rôle clairement visible ?
- [ ] Yeux désaxés (pupilles décalées) ?
- [ ] Nœuds bien nommés (LeftEyelid, RightEyelid, etc.) ?
- [ ] Hérite de BrokenFolkCharacter ?

Si oui, donne-moi le code complet des 2 fichiers.
```

---

## 💡 Comment l'utiliser

1. **Ouvre Cursor** (ou ton terminal avec Claude Code)
2. **Place-toi** dans ton projet Godot
3. **Copie-colle** le prompt ci-dessus
4. **Remplace** les `[CROCHETS]` par tes valeurs
5. **Lance** la commande
6. Claude Code te génère les 2 fichiers (.gd + .tscn)
7. **Teste** dans Godot

---

## 🎨 Exemple concret d'utilisation

Voici un exemple rempli pour créer "Le Voyageur" :

```
NOM DU PERSO : Le Voyageur
MÉTIER/RÔLE : voyageur avec gros sac à dos et bâton de marche
COULEUR DOMINANTE : STORM_BLUE
```

Et tu envoies au reste du prompt magique. En 30 secondes tu as ton 4ème perso.

---

## ⚡ Pour aller plus vite : variantes du prompt

### Version courte (quand tu as déjà compris le système)

```
Crée perso Broken Folk pour Godot 4 :
- Nom : [NOM]
- Métier : [MÉTIER]
- Couleur : [COULEUR_PALETTE]
- Doit hériter de BrokenFolkCharacter
- Respecter Bible Visuelle (asymétries, palette officielle, étoiles 
  dorées auto)
- Livre : .gd + .tscn

Vas-y.
```

### Version reskin (pour une nouvelle app)

```
Reskin un perso existant Broken Folk pour ma nouvelle app "[NOM_APP]".

Perso de base : [PERSO_EXISTANT, ex: storyteller.tscn]
Nouveau thème : [THÈME, ex: "version automne" ou "version sous-marin"]

Garde la classe parente BrokenFolkCharacter et les règles de marque, 
mais change :
- Palette utilisée (toujours dans les 10 couleurs officielles)
- Accessoires/métier
- Couleur dominante

Livre : .gd + .tscn
```

---

## 🌟 Astuce pro

**Garde une liste de tes persos créés** dans un fichier `personnages.md` :

```
1. Le Conteur (Moss Green) — utilisé dans : Portal Blast (menu)
2. La Sorcière (Eggplant) — utilisé dans : Portal Blast (game over)
3. Le Forgeron (Copper) — utilisé dans : Portal Blast (shop)
4. Le Voyageur (Storm Blue) — utilisé dans : Wandering Tales (menu)
5. ...
```

Ça t'évite de recréer 2 fois le même perso, et tu as une vue d'ensemble 
de ta "famille" qui grandit.
