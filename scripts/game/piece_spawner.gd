extends Node2D
## Zone des 3 pièces — génère et gère les pièces disponibles

signal pieces_refreshed

const SLOT_SPACING: float = 220.0
var piece_scene: PackedScene = preload("res://scenes/components/piece.tscn")
var slots: Array = [null, null, null]

func _ready() -> void:
	spawn_new_pieces()

func spawn_new_pieces() -> void:
	# Supprime les anciennes pièces
	for i in range(3):
		if slots[i] != null:
			slots[i].queue_free()
			slots[i] = null

	# Crée 3 nouvelles pièces
	for i in range(3):
		var piece: Node2D = piece_scene.instantiate()
		var shape: Array = ShapesData.get_random_shape()
		var block_type: Dictionary = ShapesData.get_random_block_type()
		piece.setup(shape, block_type["color"], block_type["symbol"])
		piece.position = Vector2((i - 1) * SLOT_SPACING, 0)
		piece.original_position = piece.position
		add_child(piece)
		slots[i] = piece

		# Animation d'apparition
		piece.scale = Vector2.ZERO
		var tween: Tween = create_tween()
		tween.tween_property(piece, "scale", Vector2.ONE, 0.3)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)\
			.set_delay(i * 0.1)

	pieces_refreshed.emit()

func remove_piece(piece: Node2D) -> void:
	for i in range(3):
		if slots[i] == piece:
			slots[i].queue_free()
			slots[i] = null
			break

func all_used() -> bool:
	for slot in slots:
		if slot != null:
			return false
	return true

func get_remaining_pieces() -> Array:
	var remaining: Array = []
	for slot in slots:
		if slot != null:
			remaining.append({"shape": slot.shape, "color": slot.color, "symbol": slot.symbol})
	return remaining

func get_all_piece_nodes() -> Array:
	var pieces: Array = []
	for slot in slots:
		if slot != null:
			pieces.append(slot)
	return pieces
