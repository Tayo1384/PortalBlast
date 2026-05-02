extends BrokenFolkCharacter
class_name WitchCharacter
## La Sorcière — Magicienne / Bonus
## Chapeau pointu cassé, robe violette, potion fumante en main.

func _ready_character() -> void:
	primary_color = EGGPLANT
	secondary_color = MOSS_GREEN
	eye_color = MOSS_GREEN
	star_count = 5  # Plus d'étoiles, plus magique


func _process_character(delta: float) -> void:
	# Léger balancement vers la gauche (perso gaucher)
	var sway: float = sin(idle_time * 1.0) * 0.015
	rotation = -0.05 + sway
	
	# Anime la fumée de la potion si elle existe
	var smoke: Node = find_child("PotionSmoke", true, false)
	if smoke and smoke is Polygon2D:
		(smoke as Polygon2D).position.y = -3 + sin(idle_time * 2.5) * 1.5
