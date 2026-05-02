extends Node2D
## Pièce draggable — blocs colorés avec reflet cartoon

signal drag_started(piece: Node2D)
signal drag_ended(piece: Node2D, end_position: Vector2)

const MINI_SIZE: float = 32.0
const MINI_GAP: float = 2.0
const MINI_STEP: float = 34.0
const DRAG_OFFSET: Vector2 = Vector2(0, -150)

var shape: Array = []
var color: Color = Color.WHITE
var symbol: String = ""
var is_dragging: bool = false
var touch_index: int = -1
var original_position: Vector2 = Vector2.ZERO
var original_scale: Vector2 = Vector2.ONE

func setup(p_shape: Array, p_color: Color, p_symbol: String) -> void:
	shape = p_shape
	color = p_color
	symbol = p_symbol
	_build_visual()

func _build_visual() -> void:
	for child in get_children():
		child.queue_free()

	var block_count: int = 0
	var center: Vector2 = Vector2.ZERO
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				center += Vector2(c * MINI_STEP, r * MINI_STEP)
				block_count += 1
	if block_count > 0:
		center /= block_count

	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				var pos: Vector2 = Vector2(c * MINI_STEP, r * MINI_STEP) - center
				_create_mini_block(pos)

func _create_mini_block(pos: Vector2) -> void:
	var s: float = MINI_SIZE
	# Fond coloré
	var bg: Polygon2D = Polygon2D.new()
	bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(s, 0),
		Vector2(s, s), Vector2(0, s)
	])
	bg.color = color
	bg.position = pos
	add_child(bg)

	# Reflet cartoon (petit ovale blanc en haut à gauche)
	var shine: Polygon2D = Polygon2D.new()
	shine.polygon = PackedVector2Array([
		Vector2(5, 3), Vector2(14, 3),
		Vector2(16, 8), Vector2(13, 11),
		Vector2(5, 11), Vector2(3, 8)
	])
	shine.color = Color(1, 1, 1, 0.22)
	shine.position = pos
	add_child(shine)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		var local_pos: Vector2 = to_local(event.position)
		if _is_point_inside(local_pos) and not is_dragging:
			is_dragging = true
			touch_index = event.index
			original_position = position
			original_scale = scale
			scale = original_scale * 1.15
			drag_started.emit(self)
	else:
		if event.index == touch_index and is_dragging:
			is_dragging = false
			scale = original_scale
			drag_ended.emit(self, event.position + DRAG_OFFSET)
			touch_index = -1

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == touch_index and is_dragging:
		global_position = event.position + DRAG_OFFSET

func _is_point_inside(local_pos: Vector2) -> bool:
	var touch_margin: float = 25.0
	var rows: int = shape.size()
	var cols: int = 0
	for row in shape:
		cols = max(cols, row.size())
	var half_w: float = (cols * MINI_STEP) / 2.0 + touch_margin
	var half_h: float = (rows * MINI_STEP) / 2.0 + touch_margin
	return abs(local_pos.x) < half_w and abs(local_pos.y) < half_h

func return_to_origin() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
