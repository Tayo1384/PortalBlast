extends Node
## Gestionnaire audio — SFX et musique
## Autoload : accessible partout via AudioManager

var sfx_volume: float = 1.0
var music_volume: float = 0.7
var muted: bool = false
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready() -> void:
	for i in range(8):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_sfx(name: String) -> void:
	if muted: return
	var path: String = "res://assets/sounds/" + name + ".wav"
	if not ResourceLoader.exists(path):
		path = "res://assets/sounds/" + name + ".ogg"
	if not ResourceLoader.exists(path): return
	for p in sfx_players:
		if not p.playing:
			p.stream = load(path)
			p.volume_db = linear_to_db(sfx_volume)
			p.play()
			return

func play_music(name: String) -> void:
	if muted: return
	var path: String = "res://assets/music/" + name + ".ogg"
	if not ResourceLoader.exists(path): return
	music_player.stream = load(path)
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func toggle_mute() -> void:
	muted = not muted
	if muted: music_player.stop()
