extends BrokenFolkCharacter
class_name BlacksmithCharacter
## Le Forgeron — Artisan / Récompenses
## Tablier de cuir, marteau, barbe rousse, posture trapue.

func _ready_character() -> void:
	primary_color = COPPER
	secondary_color = LEATHER
	eye_color = OLD_INK
	star_count = 3  # Moins d'étoiles, plus terre-à-terre


func _process_character(_delta: float) -> void:
	# Léger balancement (perso solide, peu de mouvement)
	var sway: float = sin(idle_time * 0.9) * 0.008
	rotation = sway
