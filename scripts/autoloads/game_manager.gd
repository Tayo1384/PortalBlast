extends Node
## Gestionnaire global du jeu — Score, état, sauvegarde, niveaux

signal score_changed(new_score: int)
signal high_score_beaten
signal lines_cleared(count: int, combo: int)
signal game_over
signal game_started
signal level_up(new_level: int)
signal xp_gained(amount: int)

var score: int = 0
var high_score: int = 0
var is_game_over: bool = false
var games_played: int = 0
var total_lines_cleared: int = 0
var current_game_lines: int = 0
var streak: int = 0
var best_combo: int = 0

# Système de niveaux
var level: int = 1
var xp: int = 0
var last_xp_gained: int = 0
var last_xp_base: int = 0
var last_xp_score: int = 0
var last_xp_lines: int = 0
var did_level_up: bool = false
var levels_gained: int = 0

# Consentement GDPR (0=pas demandé, 1=accepté, 2=refusé)
var ads_consent: int = 0

const SAVE_PATH: String = "user://save_data.cfg"

# Titres de rang selon le niveau
const LEVEL_TITLES: Array = [
	[1, "Apprenti"],
	[6, "Initié"],
	[11, "Artisan"],
	[16, "Maître"],
	[21, "Ancien"],
	[31, "Sage"],
	[41, "Légende"],
	[51, "Éternel"],
]

func _ready() -> void:
	load_data()

# Courbe d'XP : facile au début, exponentielle ensuite
func xp_for_next_level(lvl: int) -> int:
	return 25 + lvl * 15 + int(pow(lvl, 1.8))

func get_level_title(lvl: int = -1) -> String:
	if lvl < 0:
		lvl = level
	var title: String = "Apprenti"
	for entry in LEVEL_TITLES:
		if lvl >= entry[0]:
			title = entry[1]
	return title

func get_xp_progress() -> float:
	var needed: int = xp_for_next_level(level)
	if needed <= 0:
		return 1.0
	return clampf(float(xp) / float(needed), 0.0, 1.0)

func start_new_game() -> void:
	score = 0
	is_game_over = false
	streak = 0
	current_game_lines = 0
	games_played += 1
	game_started.emit()
	save_data()

func end_game() -> void:
	is_game_over = true
	if score > high_score:
		high_score = score
		high_score_beaten.emit()
	_award_end_game_xp()
	game_over.emit()
	save_data()

func _award_end_game_xp() -> void:
	last_xp_base = 10
	last_xp_score = int(score / 5.0)
	last_xp_lines = current_game_lines * 3
	var gained: int = last_xp_base + last_xp_score + last_xp_lines
	last_xp_gained = gained
	did_level_up = false
	levels_gained = 0
	xp += gained
	var old_level: int = level
	while xp >= xp_for_next_level(level):
		xp -= xp_for_next_level(level)
		level += 1
	levels_gained = level - old_level
	if levels_gained > 0:
		did_level_up = true
		level_up.emit(level)
	xp_gained.emit(gained)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func add_score_for_clear(cleared: int, blocks_placed: int) -> void:
	var points: int = blocks_placed
	if cleared > 0:
		var multiplier: int = 1
		if cleared == 2: multiplier = 2
		elif cleared == 3: multiplier = 3
		elif cleared >= 4: multiplier = 5
		points += cleared * 10 * multiplier
		streak += 1
		if streak > 2: points += (streak - 2) * 5
		total_lines_cleared += cleared
		current_game_lines += cleared
		if multiplier > best_combo: best_combo = multiplier
		lines_cleared.emit(cleared, multiplier)
	else:
		streak = 0
	add_score(points)

func save_data() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("stats", "high_score", high_score)
	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "total_lines_cleared", total_lines_cleared)
	config.set_value("stats", "best_combo", best_combo)
	config.set_value("progression", "level", level)
	config.set_value("progression", "xp", xp)
	config.set_value("settings", "ads_consent", ads_consent)
	config.save(SAVE_PATH)

func load_data() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SAVE_PATH) != OK: return
	high_score = config.get_value("stats", "high_score", 0)
	games_played = config.get_value("stats", "games_played", 0)
	total_lines_cleared = config.get_value("stats", "total_lines_cleared", 0)
	best_combo = config.get_value("stats", "best_combo", 0)
	level = config.get_value("progression", "level", 1)
	xp = config.get_value("progression", "xp", 0)
	ads_consent = config.get_value("settings", "ads_consent", 0)
