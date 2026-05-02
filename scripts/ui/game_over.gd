extends Node2D
## Écran de fin de partie — score, record, récap XP, niveau

const GOLD: Color = Color("#d4af37")
const OLD_INK: Color = Color("#3a2818")

var is_new_record: bool = false

@onready var final_score_label: Label = $ScorePanel/FinalScoreValue
@onready var record_label: Label = $ScorePanel/RecordValue
@onready var new_record_label: Label = $NewRecordLabel
@onready var witch: Node2D = $Witch
@onready var continue_button: Button = $ContinueButton
@onready var xp_base_value: Label = $XPPanel/XPBaseValue
@onready var xp_score_value: Label = $XPPanel/XPScoreValue
@onready var xp_lines_value: Label = $XPPanel/XPLinesValue
@onready var xp_total_label: Label = $XPPanel/XPTotalLabel
@onready var xp_bar: ProgressBar = $XPPanel/XPBar
@onready var level_label: Label = $XPPanel/LevelLabel
@onready var level_up_label: Label = $LevelUpLabel

func _ready() -> void:
	is_new_record = GameManager.score >= GameManager.high_score and GameManager.score > 0

	_animate_score_counter()
	record_label.text = str(GameManager.high_score)

	_setup_xp_display()

	witch.reaction_surprised()
	if is_new_record:
		new_record_label.visible = true
		_pulse_new_record()
		await get_tree().create_timer(0.5).timeout
		witch.reaction_victory()
	else:
		new_record_label.visible = false

func _setup_xp_display() -> void:
	level_label.text = "Niv. " + str(GameManager.level) + " — " + GameManager.get_level_title()
	var needed: int = GameManager.xp_for_next_level(GameManager.level)
	xp_bar.max_value = needed
	xp_bar.value = GameManager.xp

	# Commence tout caché
	xp_base_value.modulate = Color(1, 1, 1, 0)
	xp_score_value.modulate = Color(1, 1, 1, 0)
	xp_lines_value.modulate = Color(1, 1, 1, 0)
	xp_total_label.modulate = Color(1, 1, 1, 0)
	xp_base_value.text = "+ " + str(GameManager.last_xp_base)
	xp_score_value.text = "+ " + str(GameManager.last_xp_score)
	xp_lines_value.text = "+ " + str(GameManager.last_xp_lines)
	xp_total_label.text = "= " + str(GameManager.last_xp_gained) + " XP"

	# Animation séquentielle ligne par ligne
	var tween: Tween = create_tween()
	tween.tween_property(xp_base_value, "modulate:a", 1.0, 0.25).set_delay(0.8)
	tween.tween_property(xp_score_value, "modulate:a", 1.0, 0.25).set_delay(0.2)
	tween.tween_property(xp_lines_value, "modulate:a", 1.0, 0.25).set_delay(0.2)
	tween.tween_property(xp_total_label, "modulate:a", 1.0, 0.25).set_delay(0.3)
	# Petit scale bounce sur le total
	tween.tween_property(xp_total_label, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(xp_total_label, "scale", Vector2.ONE, 0.15)

	if GameManager.did_level_up:
		level_up_label.visible = false
		tween.tween_callback(_show_level_up).set_delay(0.4)
	else:
		level_up_label.visible = false

func _show_level_up() -> void:
	level_up_label.text = "✦ NIVEAU " + str(GameManager.level) + " ✦\n" + GameManager.get_level_title()
	level_up_label.visible = true
	level_up_label.scale = Vector2.ZERO
	level_up_label.pivot_offset = level_up_label.size / 2.0
	level_up_label.modulate = Color(GOLD, 1.0)

	var tween: Tween = create_tween()
	tween.tween_property(level_up_label, "scale", Vector2(1.3, 1.3), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(level_up_label, "scale", Vector2.ONE, 0.15)

	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(level_up_label, "modulate:a", 0.6, 0.5).set_delay(0.5)
	pulse.tween_property(level_up_label, "modulate:a", 1.0, 0.5)

	AudioManager.play_sfx("level_up")
	witch.reaction_victory()

func _animate_score_counter() -> void:
	var target: int = GameManager.score
	var tween: Tween = create_tween()
	tween.tween_method(func(val: int): final_score_label.text = str(val), 0, target, 1.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _pulse_new_record() -> void:
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(new_record_label, "modulate:a", 0.5, 0.6)
	tween.tween_property(new_record_label, "modulate:a", 1.0, 0.6)

func _on_continue_pressed() -> void:
	AudioManager.play_sfx("click")
	continue_button.disabled = true
	AdManager.show_rewarded()
	var success: bool = await AdManager.rewarded_completed
	if success:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		continue_button.disabled = false

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("click")
	AdManager.show_interstitial_smart()
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_home_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
