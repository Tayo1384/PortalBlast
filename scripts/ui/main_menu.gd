extends Node2D

@onready var title_portal: Label = $TitlePortal
@onready var title_blast: Label = $TitleBlast
@onready var tagline: Label = $Tagline
@onready var high_score_label: Label = $HighScoreLabel
@onready var start_button: Button = $StartButton
@onready var mute_button: Button = $MuteButton
@onready var storyteller: Node2D = $Storyteller
@onready var title_decoration: Node2D = $TitleDecoration
@onready var level_panel: Panel = $LevelPanel
@onready var level_label: Label = $LevelPanel/LevelLabel
@onready var level_title_label: Label = $LevelPanel/LevelTitleLabel
@onready var xp_bar: ProgressBar = $LevelPanel/XPBar
@onready var xp_label: Label = $LevelPanel/XPLabel

var _storyteller_base_y: float = 0.0
var _idle_time: float = 0.0
var _entrance_done: bool = false

func _ready() -> void:
	if GameManager.high_score > 0:
		high_score_label.text = "★ Record : " + str(GameManager.high_score)
		high_score_label.visible = true
	else:
		high_score_label.visible = false

	_storyteller_base_y = storyteller.position.y
	_update_level_display()
	_update_mute_button()
	_animate_entrance()

	if GameManager.ads_consent == 0:
		await get_tree().create_timer(1.2).timeout
		_show_consent_popup()

func _process(delta: float) -> void:
	if not _entrance_done:
		return
	_idle_time += delta
	storyteller.position.y = _storyteller_base_y + sin(_idle_time * 0.7) * 3.0

func _update_level_display() -> void:
	level_label.text = "Niv. " + str(GameManager.level)
	level_title_label.text = GameManager.get_level_title()

	var needed: int = GameManager.xp_for_next_level(GameManager.level)
	xp_bar.max_value = needed
	xp_bar.value = GameManager.xp
	xp_label.text = str(GameManager.xp) + " / " + str(needed) + " XP"

func _animate_entrance() -> void:
	var elements: Array = [
		level_panel, storyteller, title_decoration,
		title_portal, title_blast, tagline,
		high_score_label, start_button
	]
	for el in elements:
		el.modulate = Color(1, 1, 1, 0)

	var st_orig_x := storyteller.position.x
	storyteller.position.x -= 60

	start_button.pivot_offset = Vector2(
		(start_button.offset_right - start_button.offset_left) / 2.0,
		(start_button.offset_bottom - start_button.offset_top) / 2.0
	)
	start_button.scale = Vector2(0.85, 0.85)

	var tween := create_tween()

	for i in range(elements.size()):
		tween.parallel().tween_property(elements[i], "modulate:a", 1.0, 0.35)\
			.set_delay(i * 0.12)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(storyteller, "position:x", st_orig_x, 0.55)\
		.set_delay(0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	var btn_delay := (elements.size() - 1) * 0.12
	tween.parallel().tween_property(start_button, "scale", Vector2.ONE, 0.45)\
		.set_delay(btn_delay)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_callback(func(): _entrance_done = true)

func _show_consent_popup() -> void:
	var popup: CanvasLayer = preload("res://scenes/consent_popup.tscn").instantiate()
	add_child(popup)
	var accepted: bool = await popup.consent_given
	GameManager.ads_consent = 1 if accepted else 2
	GameManager.save_data()
	if accepted:
		AdManager.enable_ads()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("click")
	start_button.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))

func _on_mute_pressed() -> void:
	AudioManager.toggle_mute()
	_update_mute_button()

func _update_mute_button() -> void:
	mute_button.text = "🔇" if AudioManager.muted else "🔊"
