extends Node2D
## Grille de jeu 8x8 — cœur du gameplay

signal piece_placed(blocks_count: int)
signal lines_cleared(count: int, positions: Array)

const GRID_SIZE: int = 8
const CELL_SIZE: float = 56.0
const CELL_GAP: float = 2.0
const CELL_STEP: float = 58.0
const OLD_INK: Color = Color(0.5, 0.47, 0.42)
const GOLD_DUST: Color = Color("#d4af37")

var cells: Array = []
var ghost_cells: Array = []
var cell_scene: PackedScene = preload("res://scenes/components/cell.tscn")

@onready var border: Line2D = $Border

func _ready() -> void:
	_create_grid()
	_update_border()
	_draw_corner_ornaments()

func _create_grid() -> void:
	var total_size: float = GRID_SIZE * CELL_STEP
	var offset_x: float = -total_size / 2.0
	var offset_y: float = -total_size / 2.0

	for row in range(GRID_SIZE):
		var row_cells: Array = []
		for col in range(GRID_SIZE):
			var cell: Node2D = cell_scene.instantiate()
			cell.position = Vector2(
				offset_x + col * CELL_STEP,
				offset_y + row * CELL_STEP
			)
			add_child(cell)
			row_cells.append(cell)
		cells.append(row_cells)

func _update_border() -> void:
	var total_size: float = GRID_SIZE * CELL_STEP
	var half: float = total_size / 2.0
	var m: float = 5.0
	border.points = PackedVector2Array([
		Vector2(-half - m, -half - m),
		Vector2(half + m, -half - m),
		Vector2(half + m, half + m),
		Vector2(-half - m, half + m),
		Vector2(-half - m, -half - m)
	])

func _draw_corner_ornaments() -> void:
	var total_size: float = GRID_SIZE * CELL_STEP
	var half: float = total_size / 2.0
	var m: float = 5.0
	var ornament_col: Color = Color(GOLD_DUST, 0.5)
	var corners: Array = [
		Vector2(-half - m, -half - m),
		Vector2(half + m, -half - m),
		Vector2(half + m, half + m),
		Vector2(-half - m, half + m),
	]
	# Étoile dorée dans chaque coin
	for corner in corners:
		var star: Polygon2D = Polygon2D.new()
		star.polygon = PackedVector2Array([
			Vector2(0, -6), Vector2(2, 0),
			Vector2(0, 6), Vector2(-2, 0)
		])
		star.color = ornament_col
		star.position = corner
		add_child(star)

	# Fioritures sur les bords (petits losanges au milieu de chaque côté)
	var mid_positions: Array = [
		Vector2(0, -half - m),
		Vector2(half + m, 0),
		Vector2(0, half + m),
		Vector2(-half - m, 0),
	]
	for mid in mid_positions:
		var diamond: Polygon2D = Polygon2D.new()
		diamond.polygon = PackedVector2Array([
			Vector2(0, -4), Vector2(3, 0),
			Vector2(0, 4), Vector2(-3, 0)
		])
		diamond.color = ornament_col
		diamond.position = mid
		add_child(diamond)

func can_place_piece(shape: Array, row: int, col: int) -> bool:
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				var gr: int = row + r
				var gc: int = col + c
				if gr < 0 or gr >= GRID_SIZE or gc < 0 or gc >= GRID_SIZE:
					return false
				if cells[gr][gc].is_filled:
					return false
	return true

func place_piece(shape: Array, color: Color, symbol: String, row: int, col: int) -> void:
	var count: int = 0
	var block_index: int = 0
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				var delay: float = block_index * 0.035
				cells[row + r][col + c].set_filled(color, symbol, true, delay)
				count += 1
				block_index += 1
	piece_placed.emit(count)

func check_and_clear_lines() -> Dictionary:
	var rows_to_clear: Array = []
	var cols_to_clear: Array = []

	for row in range(GRID_SIZE):
		var full: bool = true
		for col in range(GRID_SIZE):
			if not cells[row][col].is_filled:
				full = false
				break
		if full:
			rows_to_clear.append(row)

	for col in range(GRID_SIZE):
		var full: bool = true
		for row in range(GRID_SIZE):
			if not cells[row][col].is_filled:
				full = false
				break
		if full:
			cols_to_clear.append(col)

	var cleared_positions: Array = []

	for row in rows_to_clear:
		for col in range(GRID_SIZE):
			cleared_positions.append(Vector2i(row, col))
			cells[row][col].clear_with_animation()

	for col in cols_to_clear:
		for row in range(GRID_SIZE):
			var pos: Vector2i = Vector2i(row, col)
			if pos not in cleared_positions:
				cleared_positions.append(pos)
				cells[row][col].clear_with_animation()

	var total_cleared: int = rows_to_clear.size() + cols_to_clear.size()
	if total_cleared > 0:
		lines_cleared.emit(total_cleared, cleared_positions)

	return {"cleared": total_cleared, "positions": cleared_positions}

func is_game_over(available_pieces: Array) -> bool:
	for piece_data in available_pieces:
		var shape: Array = piece_data["shape"]
		for row in range(GRID_SIZE):
			for col in range(GRID_SIZE):
				if can_place_piece(shape, row, col):
					return false
	return true

func show_ghost(shape: Array, row: int, col: int, color: Color) -> void:
	clear_ghost()
	if not can_place_piece(shape, row, col):
		return
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				cells[row + r][col + c].show_ghost(color)
				ghost_cells.append(Vector2i(row + r, col + c))

func clear_ghost() -> void:
	for pos in ghost_cells:
		if pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE:
			cells[pos.x][pos.y].clear_ghost()
	ghost_cells.clear()

func global_to_grid(gpos: Vector2) -> Vector2i:
	var local_pos: Vector2 = to_local(gpos)
	var total_size: float = GRID_SIZE * CELL_STEP
	var half: float = total_size / 2.0
	var col: int = floori((local_pos.x + half) / CELL_STEP)
	var row: int = floori((local_pos.y + half) / CELL_STEP)
	return Vector2i(row, col)
