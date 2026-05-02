extends CanvasLayer

signal consent_given(accepted: bool)

func _on_accept_pressed() -> void:
	AudioManager.play_sfx("click")
	consent_given.emit(true)
	queue_free()

func _on_refuse_pressed() -> void:
	AudioManager.play_sfx("click")
	consent_given.emit(false)
	queue_free()
