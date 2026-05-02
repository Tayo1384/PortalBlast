extends Node2D
class_name BrokenFolkCharacter
## Classe parente pour TOUS les personnages "Broken Folk" de ta marque.
## Contient toutes les règles de la Bible Visuelle.
##
## Pour créer un nouveau perso :
##   extends BrokenFolkCharacter
##   class_name MonNouveauPerso
##
## Tu hérites automatiquement :
## - Palette officielle Broken Folk
## - Animations idle (respiration légère, balancement)
## - Étoiles dorées scintillantes (signature)
## - Système de réactions (excited, surprised, victory)
## - Asymétries automatiques

# ============================================================
# PALETTE OFFICIELLE — LES 10 COULEURS BROKEN FOLK
# ============================================================
# JAMAIS d'autres couleurs.

const PARCHMENT: Color = Color("#f4ead5")     # Fond clair
const OLD_INK: Color = Color("#3a2818")       # Contours
const LEATHER: Color = Color("#5a3818")       # Cuir, bois sombre
const RUST_RED: Color = Color("#c4615e")      # Rouge brique
const MOSS_GREEN: Color = Color("#7a8b3d")    # Vert mousse
const EGGPLANT: Color = Color("#7a4878")      # Violet aubergine
const STORM_BLUE: Color = Color("#3a4878")    # Bleu orage
const COPPER: Color = Color("#a55838")        # Cuivre
const SKIN_WARM: Color = Color("#e8c8a4")     # Peau
const BONE_WHITE: Color = Color("#f0e8d0")    # Os, ivoire
const GOLD_DUST: Color = Color("#d4af37")     # MAGIE (signature)


# ============================================================
# CONSTANTES DE STYLE — RÈGLES NON-NÉGOCIABLES
# ============================================================

const CONTOUR_WIDTH_MAIN: float = 2.5
const CONTOUR_WIDTH_INNER: float = 2.0
const CONTOUR_WIDTH_DETAIL: float = 1.2
const ASYMMETRY_RATIO_EYES: float = 1.3      # Œil gauche 30% plus grand
const STAR_COUNT_MIN: int = 3
const STAR_COUNT_MAX: int = 5


# ============================================================
# VARIABLES PERSONNALISABLES
# ============================================================

## Couleur principale du perso (override dans chaque enfant)
@export var primary_color: Color = MOSS_GREEN
## Couleur secondaire pour les détails
@export var secondary_color: Color = COPPER
## Couleur des yeux (lumineuse)
@export var eye_color: Color = OLD_INK
## Active/désactive les animations
@export var enabled_animations: bool = true
## Nombre d'étoiles dorées flottantes
@export var star_count: int = 4


# ============================================================
# VARIABLES INTERNES
# ============================================================

var idle_time: float = 0.0
var blink_timer: float = 0.0
var next_blink_time: float = 3.0
var is_blinking: bool = false
var stars: Array[Polygon2D] = []
var star_offsets: Array[Vector2] = []


# ============================================================
# INITIALISATION
# ============================================================
func _ready() -> void:
	# Programme le premier clignement
	next_blink_time = randf_range(2.5, 5.0)
	
	# Crée les étoiles dorées signature
	_create_signature_stars()
	
	# Init custom des enfants
	_ready_character()


## Override dans les enfants pour init custom
func _ready_character() -> void:
	pass


# ============================================================
# CRÉATION DES ÉTOILES DORÉES SIGNATURE
# ============================================================
func _create_signature_stars() -> void:
	# Position aléatoire mais répartie autour du perso
	var positions: Array[Vector2] = [
		Vector2(-70, -100),
		Vector2(75, -90),
		Vector2(-85, -20),
		Vector2(80, -30),
		Vector2(-60, 50)
	]
	
	for i in range(min(star_count, positions.size())):
		var star: Polygon2D = _create_gold_star(2.0 + randf() * 1.5)
		star.position = positions[i] + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		add_child(star)
		stars.append(star)
		star_offsets.append(star.position)


## Crée une étoile dorée à 4 branches (losange)
func _create_gold_star(size: float) -> Polygon2D:
	var star: Polygon2D = Polygon2D.new()
	star.polygon = PackedVector2Array([
		Vector2(0, -size * 1.5),
		Vector2(size * 0.4, 0),
		Vector2(0, size * 1.5),
		Vector2(-size * 0.4, 0)
	])
	star.color = GOLD_DUST
	return star


# ============================================================
# BOUCLE D'ANIMATION
# ============================================================
func _process(delta: float) -> void:
	if not enabled_animations:
		return
	
	idle_time += delta
	blink_timer += delta
	
	# === Respiration douce ===
	# Plus subtile que les styles cartoon (on est dans le contemplatif)
	var breath: float = sin(idle_time * 1.4) * 0.008
	scale = Vector2(1.0 + breath, 1.0 + breath)
	
	# === Étoiles dorées qui scintillent et flottent ===
	for i in range(stars.size()):
		var star: Polygon2D = stars[i]
		var base_pos: Vector2 = star_offsets[i]
		
		# Flottement vertical doux
		var float_y: float = sin(idle_time * 0.8 + i * 1.5) * 4.0
		var float_x: float = cos(idle_time * 0.6 + i * 2.0) * 3.0
		star.position = base_pos + Vector2(float_x, float_y)
		
		# Scintillement (taille qui pulse)
		var twinkle: float = 0.7 + (sin(idle_time * 2.0 + i * 1.7) + 1.0) * 0.3
		star.scale = Vector2(twinkle, twinkle)
		
		# Rotation lente
		star.rotation += delta * (0.3 + i * 0.1)
	
	# === Animation custom des enfants ===
	_process_character(delta)
	
	# === Clignement des yeux ===
	if blink_timer >= next_blink_time and not is_blinking:
		_blink()


## Override dans les enfants pour animation custom
func _process_character(_delta: float) -> void:
	pass


# ============================================================
# CLIGNEMENT DES YEUX
# ============================================================
func _blink() -> void:
	is_blinking = true
	
	var left_lid: Node = find_child("LeftEyelid", true, false)
	var right_lid: Node = find_child("RightEyelid", true, false)
	
	if left_lid:
		left_lid.visible = true
	if right_lid:
		right_lid.visible = true
	
	# Clignement lent (style contemplatif)
	await get_tree().create_timer(0.18).timeout
	
	if left_lid:
		left_lid.visible = false
	if right_lid:
		right_lid.visible = false
	
	is_blinking = false
	blink_timer = 0.0
	# Intervalle plus long que cartoon (perso plus calme)
	next_blink_time = randf_range(3.5, 7.0)


# ============================================================
# RÉACTIONS COMMUNES (à utiliser depuis ton jeu)
# ============================================================

## Réaction d'excitation : le perso bondit doucement
func reaction_excited() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 8, 0.2)
	tween.chain().tween_property(self, "position:y", position.y, 0.3)\
		.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	
	# Les étoiles brillent plus fort
	for star in stars:
		var star_tween: Tween = create_tween()
		star_tween.tween_property(star, "modulate", Color(1.5, 1.3, 1.0, 1.0), 0.2)
		star_tween.tween_property(star, "modulate", Color.WHITE, 0.4)


## Réaction de surprise : les yeux s'agrandissent
func reaction_surprised() -> void:
	var left_eye: Node = find_child("LeftEyeWhite", true, false)
	var right_eye: Node = find_child("RightEyeWhite", true, false)
	
	if not left_eye or not right_eye:
		return
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(left_eye, "scale", Vector2(1.4, 1.4), 0.15)
	tween.tween_property(right_eye, "scale", Vector2(1.4, 1.4), 0.15)
	tween.chain().tween_property(left_eye, "scale", Vector2(1.0, 1.0), 0.4)
	tween.chain().tween_property(right_eye, "scale", Vector2(1.0, 1.0), 0.4)


## Réaction de victoire : pluie d'étoiles dorées
func reaction_victory() -> void:
	# Spawn d'étoiles supplémentaires temporaires
	for i in range(8):
		var star: Polygon2D = _create_gold_star(2.5 + randf() * 2.0)
		star.position = Vector2(randf_range(-90, 90), randf_range(-120, 30))
		add_child(star)
		
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(star, "position:y", star.position.y - 50, 1.2)
		tween.tween_property(star, "modulate:a", 0.0, 1.2)
		tween.tween_property(star, "rotation", PI * 2, 1.2)
		await get_tree().create_timer(0.05).timeout
	
	# Léger pulse du perso
	var pulse: Tween = create_tween()
	pulse.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	pulse.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)


# ============================================================
# UTILITAIRES POUR LES ENFANTS
# ============================================================

## Crée un Polygon2D avec contour Old Ink automatique
## Avec légère asymétrie volontaire dans les points (style fait main)
func add_polygon_with_contour(parent: Node, points: PackedVector2Array, fill_color: Color, contour_width: float = -1.0) -> Node2D:
	if contour_width < 0:
		contour_width = CONTOUR_WIDTH_MAIN
	
	var container: Node2D = Node2D.new()
	parent.add_child(container)
	
	# Polygone rempli
	var polygon: Polygon2D = Polygon2D.new()
	polygon.polygon = points
	polygon.color = fill_color
	container.add_child(polygon)
	
	# Contour Old Ink
	var contour: Line2D = Line2D.new()
	contour.points = points
	contour.add_point(points[0])
	contour.width = contour_width
	contour.default_color = OLD_INK
	contour.joint_mode = Line2D.LINE_JOINT_ROUND
	contour.begin_cap_mode = Line2D.LINE_CAP_ROUND
	contour.end_cap_mode = Line2D.LINE_CAP_ROUND
	container.add_child(contour)
	
	return container


## Applique une légère asymétrie aux points (style fait main)
## À utiliser quand tu crées tes polygones manuellement
static func add_handmade_wobble(points: PackedVector2Array, intensity: float = 1.0) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for p in points:
		var wobble: Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		result.append(p + wobble)
	return result
