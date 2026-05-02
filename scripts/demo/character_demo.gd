extends Node2D
## Démo des 3 personnages Broken Folk
## Permet de tester les réactions sur tous les persos en même temps

@onready var storyteller: Node2D = $Storyteller
@onready var witch: Node2D = $Witch
@onready var blacksmith: Node2D = $Blacksmith

@onready var excited_btn: Button = $UI/ButtonContainer/ExcitedBtn
@onready var surprised_btn: Button = $UI/ButtonContainer/SurprisedBtn
@onready var victory_btn: Button = $UI/ButtonContainer/VictoryBtn


func _ready() -> void:
	excited_btn.pressed.connect(_on_excited_pressed)
	surprised_btn.pressed.connect(_on_surprised_pressed)
	victory_btn.pressed.connect(_on_victory_pressed)


func _on_excited_pressed() -> void:
	storyteller.reaction_excited()
	# Léger délai pour effet "vague"
	await get_tree().create_timer(0.1).timeout
	witch.reaction_excited()
	await get_tree().create_timer(0.1).timeout
	blacksmith.reaction_excited()


func _on_surprised_pressed() -> void:
	storyteller.reaction_surprised()
	witch.reaction_surprised()
	blacksmith.reaction_surprised()


func _on_victory_pressed() -> void:
	storyteller.reaction_victory()
	await get_tree().create_timer(0.15).timeout
	witch.reaction_victory()
	await get_tree().create_timer(0.15).timeout
	blacksmith.reaction_victory()
