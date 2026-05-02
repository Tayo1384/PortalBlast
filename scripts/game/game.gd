extends Node2D
## Scène de jeu principale — orchestre board, pièces, score et UI

const COMBO_TEXTS: Array = ["FOLK MAGIC!", "ANCIENT POWER!", "LEGENDARY!", "GOLDEN!"]
const GOLD: Color = Color("#d4af37")
const OLD_INK: Color = Color("#3a2818")

var pause_scene: PackedScene = preload("res://scenes/pause_menu.tscn")

@onready var board: Node2D = $Board
@onready var spawner: Node2D = $PieceSpawner
@onready var score_value_label: Label = $Header/ScoreValue
@onready var high_score_label: Label = $Header/HighScoreValue
@onready var combo_label: Label = $ComboLabel

func _ready() -> void:
	GameManager.start_new_game()
	_update_score_display(0)
	high_score_label.text = str(GameManager.high_score)

	# Connecte les signaux du GameManager
	GameManager.score_changed.connect(_update_score_display)
	GameManager.lines_cleared.connect(_on_lines_cleared)

	# Connecte les signaux du spawner
	spawner.pieces_refreshed.connect(_connect_piece_signals)
	_connect_piece_signals()

func _connect_piece_signals() -> void:
	for piece in spawner.get_all_piece_nodes():
		if not piece.drag_ended.is_connected(_on_piece_drag_ended):
			piece.drag_ended.connect(_on_piece_drag_ended)
		if not piece.drag_started.is_connected(_on_piece_drag_started):
			piece.drag_started.connect(_on_piece_drag_started)

func _on_piece_drag_started(piece: Node2D) -> void:
	AudioManager.play_sfx("pick")

func _shape_center_offset(shape: Array) -> Vector2i:
	var sr: float = 0.0
	var sc: float = 0.0
	var count: int = 0
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				sr += r
				sc += c
				count += 1
	if count == 0:
		return Vector2i.ZERO
	return Vector2i(roundi(sr / count), roundi(sc / count))

func _on_piece_drag_ended(piece: Node2D, end_position: Vector2) -> void:
	var grid_pos: Vector2i = board.global_to_grid(end_position)
	var offset: Vector2i = _shape_center_offset(piece.shape)
	var row: int = grid_pos.x - offset.x
	var col: int = grid_pos.y - offset.y

	board.clear_ghost()

	if board.can_place_piece(piece.shape, row, col):
		board.place_piece(piece.shape, piece.color, piece.symbol, row, col)
		var block_count: int = _count_blocks(piece.shape)
		spawner.remove_piece(piece)
		AudioManager.play_sfx("place")
		_screen_shake(3.0, 0.15)

		# Vérifie les lignes complètes
		var result: Dictionary = board.check_and_clear_lines()
		GameManager.add_score_for_clear(result["cleared"], block_count)

		if result["cleared"] > 0:
			AudioManager.play_sfx("clear")
			_screen_shake(5.0 + result["cleared"] * 2.0, 0.25)

		# Vérifie si toutes les pièces sont utilisées
		if spawner.all_used():
			spawner.spawn_new_pieces()
			_connect_piece_signals()

		# Vérifie le game over
		if board.is_game_over(spawner.get_remaining_pieces()):
			await get_tree().create_timer(0.5).timeout
			GameManager.end_game()
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		# Placement raté, retour à l'origine
		piece.return_to_origin()
		AudioManager.play_sfx("error")

func _process(_delta: float) -> void:
	# Affiche le ghost pendant le drag
	for piece in spawner.get_all_piece_nodes():
		if piece.is_dragging:
			var grid_pos: Vector2i = board.global_to_grid(
				piece.global_position
			)
			var offset: Vector2i = _shape_center_offset(piece.shape)
			var row: int = grid_pos.x - offset.x
			var col: int = grid_pos.y - offset.y
			board.clear_ghost()
			if board.can_place_piece(piece.shape, row, col):
				board.show_ghost(piece.shape, row, col, piece.color)
			return
	board.clear_ghost()

func _update_score_display(new_score: int) -> void:
	score_value_label.text = str(new_score)

func _on_lines_cleared(count: int, _combo: int) -> void:
	# Affiche le texte de combo
	var text_index: int = clampi(count - 1, 0, COMBO_TEXTS.size() - 1)
	combo_label.text = COMBO_TEXTS[text_index]
	combo_label.visible = true
	combo_label.modulate = Color(GOLD, 1.0)
	combo_label.scale = Vector2.ZERO
	combo_label.pivot_offset = combo_label.size / 2.0

	var tween: Tween = create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(combo_label, "scale", Vector2.ONE, 0.15)
	tween.tween_interval(0.6)
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): combo_label.visible = false)

func _screen_shake(intensity: float, duration: float) -> void:
	var original_pos: Vector2 = board.position
	var tween: Tween = create_tween()
	var steps: int = int(duration / 0.03)
	for i in range(steps):
		var offset_vec: Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(board, "position", original_pos + offset_vec, 0.03)
	tween.tween_property(board, "position", original_pos, 0.03)

func _count_blocks(shape: Array) -> int:
	var count: int = 0
	for row in shape:
		for cell in row:
			if cell == 1:
				count += 1
	return count

func _on_pause_pressed() -> void:
	var pause_instance: Node = pause_scene.instantiate()
	add_child(pause_instance)
