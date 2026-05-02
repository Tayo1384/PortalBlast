extends BrokenFolkCharacter
class_name StorytellerCharacter
## Le Conteur — Mentor / Narrateur
## Manteau vert mousse brodé d'étoiles, cheveux noirs, yeux noirs expressifs.

func _ready_character() -> void:
	# Couleurs spécifiques au Conteur
	primary_color = MOSS_GREEN
	secondary_color = COPPER
	eye_color = OLD_INK
	star_count = 4


func _process_character(_delta: float) -> void:
	# Léger balancement vers la droite (perso droitier)
	var sway: float = sin(idle_time * 1.2) * 0.012
	rotation = sway
