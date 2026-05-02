extends Node2D

const GOLD := Color(0.831, 0.686, 0.216)
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 0.55 + sin(time * 1.2) * 0.2
	var col := Color(GOLD.r, GOLD.g, GOLD.b, pulse)
	var dim := Color(GOLD.r, GOLD.g, GOLD.b, pulse * 0.5)
	_draw_ornament(0.0, col, dim, 160.0)
	_draw_ornament(185.0, col, dim, 125.0)

func _draw_ornament(y: float, col: Color, dim: Color, hw: float) -> void:
	_draw_diamond(Vector2(0, y), 7.0, col)
	draw_line(Vector2(-14, y), Vector2(-hw, y), col, 1.5, true)
	draw_line(Vector2(14, y), Vector2(hw, y), col, 1.5, true)
	_draw_diamond(Vector2(-hw, y), 3.5, dim)
	_draw_diamond(Vector2(hw, y), 3.5, dim)

func _draw_diamond(pos: Vector2, sz: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -sz), pos + Vector2(sz * 0.6, 0),
		pos + Vector2(0, sz), pos + Vector2(-sz * 0.6, 0),
	]), col)
