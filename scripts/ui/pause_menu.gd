extends CanvasLayer
## Menu pause — met le jeu en pause avec options

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_update_mute_button()

func _on_resume_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	queue_free()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("click")
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_mute_pressed() -> void:
	AudioManager.toggle_mute()
	_update_mute_button()

func _update_mute_button() -> void:
	var btn: Button = $Overlay/Panel/MuteButton
	btn.text = "🔇 Son coupé" if AudioManager.muted else "🔊 Son activé"
