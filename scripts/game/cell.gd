extends Node2D
## Case de la grille — style BFDI : visages cartoon sur blocs colorés

const CELL_SIZE: float = 56.0
const OLD_INK: Color = Color("#3a2818")
const PARCHMENT: Color = Color(0.2, 0.2, 0.24)
const MOUTH_DARK: Color = Color(0.12, 0.06, 0.04, 0.9)
const TONGUE_PINK: Color = Color(0.88, 0.48, 0.5, 0.9)
const FACE_COUNT: int = 30
const _D: float = 80.0

var is_filled: bool = false
var block_color: Color = Color.WHITE
var block_symbol: String = ""
var decoration_nodes: Array = []

@onready var background: Polygon2D = $Background
@onready var contour: Line2D = $Contour

func _ready() -> void:
	clear_cell()

# Convertit une coordonnée design (base 80) vers la taille réelle
func _s(v: float) -> float:
	return v * CELL_SIZE / _D

func set_filled(color: Color, symbol: String, animate: bool = false, delay: float = 0.0) -> void:
	is_filled = true
	block_color = color
	block_symbol = symbol
	background.color = color
	contour.visible = false
	_clear_decorations()
	_draw_shine()
	_draw_face(randi() % FACE_COUNT)
	if animate:
		_play_place_effect(delay)

func _play_place_effect(delay: float) -> void:
	scale = Vector2.ZERO
	modulate = Color(2.0, 2.0, 2.0, 1.0)
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.06)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var flash_tween: Tween = create_tween()
	flash_tween.tween_interval(delay)
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func clear_cell() -> void:
	is_filled = false
	block_color = Color.WHITE
	block_symbol = ""
	background.color = Color(PARCHMENT, 0.15)
	contour.visible = true
	_clear_decorations()
	scale = Vector2.ONE
	rotation = 0.0

func clear_with_animation() -> void:
	is_filled = false
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation", deg_to_rad(90), 0.4)
	await tween.finished
	clear_cell()

func show_ghost(color: Color) -> void:
	if not is_filled:
		background.color = Color(color, 0.25)
		contour.visible = false

func clear_ghost() -> void:
	if not is_filled:
		background.color = Color(PARCHMENT, 0.15)
		contour.visible = true

# === Outils de dessin ===

func _clear_decorations() -> void:
	for node in decoration_nodes:
		if is_instance_valid(node):
			node.queue_free()
	decoration_nodes.clear()

func _poly(pts: PackedVector2Array, col: Color) -> void:
	var p: Polygon2D = Polygon2D.new()
	p.polygon = pts
	p.color = col
	add_child(p)
	decoration_nodes.append(p)

func _line(pts: PackedVector2Array, col: Color, w: float = 2.0) -> void:
	var l: Line2D = Line2D.new()
	l.points = pts
	l.default_color = col
	l.width = w
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(l)
	decoration_nodes.append(l)

func _oval(cx: float, cy: float, rx: float, ry: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var a: float = TAU * i / 10.0 - PI / 2.0
		pts.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	return pts

func _eye(cx: float, cy: float, wrx: float, wry: float, px: float, py: float, prx: float, pry: float) -> void:
	_poly(_oval(cx, cy, wrx, wry), Color.WHITE)
	_poly(_oval(cx + px, cy + py, prx, pry), OLD_INK)

func _smile(x1: float, x2: float, y: float, depth: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(8):
		var t: float = float(i) / 7.0
		pts.append(Vector2(lerpf(x1, x2, t), y + sin(t * PI) * depth))
	return pts

# === Reflet cartoon ===

func _draw_shine() -> void:
	_poly(_oval(_s(17), _s(17), _s(10), _s(7)), Color(1, 1, 1, 0.2))

# === 10 visages BFDI ===

func _draw_face(id: int) -> void:
	match id:
		0: _face_happy()
		1: _face_grin()
		2: _face_surprised()
		3: _face_chill()
		4: _face_wink()
		5: _face_excited()
		6: _face_sleepy()
		7: _face_cheeky()
		8: _face_worried()
		9: _face_derp()
		10: _face_angry()
		11: _face_smug()
		12: _face_shocked()
		13: _face_love()
		14: _face_crying()
		15: _face_cool()
		16: _face_dizzy()
		17: _face_mischievous()
		18: _face_proud()
		19: _face_confused()
		20: _face_yawn()
		21: _face_sassy()
		22: _face_nervous()
		23: _face_blush()
		24: _face_starry()
		25: _face_grumpy()
		26: _face_silly()
		27: _face_zen()
		28: _face_gasp()
		29: _face_content()

func _face_happy() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), 0, 0, _s(4), _s(4.5))
	_eye(_s(52), _s(30), _s(9), _s(10), 0, 0, _s(4), _s(4.5))
	_line(_smile(_s(22), _s(58), _s(52), _s(7)), OLD_INK, _s(2.2))

func _face_grin() -> void:
	_eye(_s(28), _s(26), _s(9), _s(10), 0, _s(-1), _s(4), _s(4.5))
	_eye(_s(52), _s(26), _s(9), _s(10), 0, _s(-1), _s(4), _s(4.5))
	_poly(PackedVector2Array([
		Vector2(_s(20), _s(48)), Vector2(_s(60), _s(48)),
		Vector2(_s(58), _s(62)), Vector2(_s(40), _s(66)), Vector2(_s(22), _s(62))
	]), MOUTH_DARK)
	_poly(PackedVector2Array([
		Vector2(_s(22), _s(48)), Vector2(_s(58), _s(48)),
		Vector2(_s(58), _s(54)), Vector2(_s(22), _s(54))
	]), Color.WHITE)

func _face_surprised() -> void:
	_eye(_s(26), _s(26), _s(11), _s(13), 0, 0, _s(3), _s(3.5))
	_eye(_s(54), _s(26), _s(11), _s(13), 0, 0, _s(3), _s(3.5))
	_poly(_oval(_s(40), _s(56), _s(7), _s(8)), MOUTH_DARK)

func _face_chill() -> void:
	_poly(_oval(_s(28), _s(32), _s(9), _s(4)), Color.WHITE)
	_poly(_oval(_s(28), _s(33), _s(4), _s(2.5)), OLD_INK)
	_poly(_oval(_s(52), _s(32), _s(9), _s(4)), Color.WHITE)
	_poly(_oval(_s(52), _s(33), _s(4), _s(2.5)), OLD_INK)
	_line(_smile(_s(30), _s(50), _s(52), _s(3)), OLD_INK, _s(1.8))

func _face_wink() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), 0, 0, _s(4), _s(4.5))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(32)), Vector2(_s(52), _s(28)), Vector2(_s(60), _s(32))
	]), OLD_INK, _s(2.2))
	_line(_smile(_s(22), _s(58), _s(52), _s(6)), OLD_INK, _s(2.2))

func _face_excited() -> void:
	_eye(_s(26), _s(26), _s(10), _s(11), 0, _s(-2), _s(2.5), _s(3))
	_eye(_s(54), _s(26), _s(10), _s(11), 0, _s(-2), _s(2.5), _s(3))
	_poly(PackedVector2Array([
		Vector2(_s(22), _s(50)), Vector2(_s(58), _s(50)),
		Vector2(_s(56), _s(64)), Vector2(_s(40), _s(70)), Vector2(_s(24), _s(64))
	]), MOUTH_DARK)

func _face_sleepy() -> void:
	_line(PackedVector2Array([
		Vector2(_s(19), _s(34)), Vector2(_s(28), _s(30)), Vector2(_s(37), _s(34))
	]), OLD_INK, _s(2.2))
	_line(PackedVector2Array([
		Vector2(_s(43), _s(34)), Vector2(_s(52), _s(30)), Vector2(_s(61), _s(34))
	]), OLD_INK, _s(2.2))
	_line(PackedVector2Array([
		Vector2(_s(30), _s(54)), Vector2(_s(50), _s(54))
	]), OLD_INK, _s(1.8))

func _face_cheeky() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(-2), 0, _s(4), _s(4.5))
	_eye(_s(52), _s(30), _s(9), _s(10), _s(-2), 0, _s(4), _s(4.5))
	_line(_smile(_s(24), _s(56), _s(50), _s(5)), OLD_INK, _s(2.0))
	_poly(PackedVector2Array([
		Vector2(_s(35), _s(55)), Vector2(_s(45), _s(55)),
		Vector2(_s(46), _s(64)), Vector2(_s(40), _s(68)), Vector2(_s(34), _s(64))
	]), TONGUE_PINK)

func _face_worried() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(1), _s(-2), _s(4), _s(4.5))
	_eye(_s(52), _s(30), _s(9), _s(10), _s(1), _s(-2), _s(4), _s(4.5))
	_line(PackedVector2Array([
		Vector2(_s(20), _s(20)), Vector2(_s(36), _s(22))
	]), Color(OLD_INK, 0.6), _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(22)), Vector2(_s(60), _s(20))
	]), Color(OLD_INK, 0.6), _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(26), _s(55)), Vector2(_s(36), _s(52)),
		Vector2(_s(48), _s(56)), Vector2(_s(56), _s(53))
	]), OLD_INK, _s(2.0))

func _face_derp() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(-3), _s(2), _s(4), _s(4.5))
	_eye(_s(52), _s(30), _s(10), _s(11), _s(3), _s(-1), _s(4.5), _s(5))
	_line(PackedVector2Array([
		Vector2(_s(24), _s(56)), Vector2(_s(34), _s(52)),
		Vector2(_s(46), _s(58)), Vector2(_s(56), _s(54))
	]), OLD_INK, _s(2.2))

func _face_angry() -> void:
	_eye(_s(28), _s(32), _s(8), _s(9), 0, _s(1), _s(4), _s(4.5))
	_eye(_s(52), _s(32), _s(8), _s(9), 0, _s(1), _s(4), _s(4.5))
	_line(PackedVector2Array([
		Vector2(_s(18), _s(20)), Vector2(_s(36), _s(26))
	]), OLD_INK, _s(2.5))
	_line(PackedVector2Array([
		Vector2(_s(62), _s(20)), Vector2(_s(44), _s(26))
	]), OLD_INK, _s(2.5))
	_line(PackedVector2Array([
		Vector2(_s(26), _s(58)), Vector2(_s(34), _s(54)),
		Vector2(_s(46), _s(54)), Vector2(_s(54), _s(58))
	]), OLD_INK, _s(2.2))

func _face_smug() -> void:
	_poly(_oval(_s(28), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(28), _s(34), _s(4), _s(2.5)), OLD_INK)
	_poly(_oval(_s(52), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(52), _s(34), _s(4), _s(2.5)), OLD_INK)
	_line(PackedVector2Array([
		Vector2(_s(30), _s(52)), Vector2(_s(40), _s(56)), Vector2(_s(56), _s(50))
	]), OLD_INK, _s(2.0))

func _face_shocked() -> void:
	_eye(_s(26), _s(26), _s(12), _s(14), 0, _s(-1), _s(2.5), _s(3))
	_eye(_s(54), _s(26), _s(12), _s(14), 0, _s(-1), _s(2.5), _s(3))
	_poly(_oval(_s(40), _s(58), _s(9), _s(11)), MOUTH_DARK)
	_poly(_oval(_s(62), _s(18), _s(3), _s(4)), Color(0.4, 0.7, 0.9, 0.5))

func _face_love() -> void:
	_poly(PackedVector2Array([
		Vector2(_s(22), _s(30)), Vector2(_s(25), _s(24)), Vector2(_s(28), _s(22)),
		Vector2(_s(31), _s(24)), Vector2(_s(34), _s(30)), Vector2(_s(28), _s(38))
	]), Color(0.9, 0.3, 0.35, 0.9))
	_poly(PackedVector2Array([
		Vector2(_s(46), _s(30)), Vector2(_s(49), _s(24)), Vector2(_s(52), _s(22)),
		Vector2(_s(55), _s(24)), Vector2(_s(58), _s(30)), Vector2(_s(52), _s(38))
	]), Color(0.9, 0.3, 0.35, 0.9))
	_line(_smile(_s(24), _s(56), _s(54), _s(7)), OLD_INK, _s(2.2))

func _face_crying() -> void:
	_eye(_s(28), _s(28), _s(9), _s(10), 0, _s(2), _s(4), _s(4.5))
	_eye(_s(52), _s(28), _s(9), _s(10), 0, _s(2), _s(4), _s(4.5))
	_line(PackedVector2Array([
		Vector2(_s(20), _s(20)), Vector2(_s(34), _s(24))
	]), OLD_INK, _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(46), _s(24)), Vector2(_s(60), _s(20))
	]), OLD_INK, _s(2.0))
	_poly(_oval(_s(22), _s(42), _s(3), _s(5)), Color(0.4, 0.7, 0.9, 0.6))
	_poly(_oval(_s(58), _s(42), _s(3), _s(5)), Color(0.4, 0.7, 0.9, 0.6))
	_line(PackedVector2Array([
		Vector2(_s(28), _s(58)), Vector2(_s(36), _s(54)),
		Vector2(_s(44), _s(54)), Vector2(_s(52), _s(58))
	]), OLD_INK, _s(2.0))

func _face_cool() -> void:
	_poly(PackedVector2Array([
		Vector2(_s(14), _s(28)), Vector2(_s(38), _s(28)),
		Vector2(_s(36), _s(38)), Vector2(_s(16), _s(38))
	]), Color(0.15, 0.15, 0.2, 0.85))
	_poly(PackedVector2Array([
		Vector2(_s(42), _s(28)), Vector2(_s(66), _s(28)),
		Vector2(_s(64), _s(38)), Vector2(_s(44), _s(38))
	]), Color(0.15, 0.15, 0.2, 0.85))
	_line(PackedVector2Array([
		Vector2(_s(38), _s(32)), Vector2(_s(42), _s(32))
	]), Color(0.15, 0.15, 0.2, 0.85), _s(2.0))
	_line(_smile(_s(26), _s(54), _s(54), _s(5)), OLD_INK, _s(2.2))

func _face_dizzy() -> void:
	var cx1: float = _s(28)
	var cy1: float = _s(30)
	var cx2: float = _s(52)
	var cy2: float = _s(30)
	var spiral1: PackedVector2Array = PackedVector2Array()
	var spiral2: PackedVector2Array = PackedVector2Array()
	for i in range(16):
		var a: float = float(i) * 1.2
		var r1: float = _s(2) + _s(0.5) * float(i)
		spiral1.append(Vector2(cx1 + cos(a) * r1, cy1 + sin(a) * r1))
		spiral2.append(Vector2(cx2 + cos(a + 0.5) * r1, cy2 + sin(a + 0.5) * r1))
	_line(spiral1, OLD_INK, _s(1.8))
	_line(spiral2, OLD_INK, _s(1.8))
	_line(PackedVector2Array([
		Vector2(_s(26), _s(56)), Vector2(_s(34), _s(54)),
		Vector2(_s(46), _s(58)), Vector2(_s(54), _s(52))
	]), OLD_INK, _s(2.0))

func _face_mischievous() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(2), _s(-1), _s(4), _s(4.5))
	_poly(_oval(_s(52), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(53), _s(33), _s(4), _s(2.5)), OLD_INK)
	_line(PackedVector2Array([
		Vector2(_s(18), _s(22)), Vector2(_s(36), _s(20))
	]), OLD_INK, _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(28), _s(52)), Vector2(_s(40), _s(56)), Vector2(_s(58), _s(48))
	]), OLD_INK, _s(2.2))

func _face_proud() -> void:
	_line(PackedVector2Array([
		Vector2(_s(20), _s(30)), Vector2(_s(28), _s(28)), Vector2(_s(36), _s(30))
	]), OLD_INK, _s(2.2))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(30)), Vector2(_s(52), _s(28)), Vector2(_s(60), _s(30))
	]), OLD_INK, _s(2.2))
	_poly(PackedVector2Array([
		Vector2(_s(22), _s(48)), Vector2(_s(58), _s(48)),
		Vector2(_s(56), _s(60)), Vector2(_s(40), _s(64)), Vector2(_s(24), _s(60))
	]), MOUTH_DARK)
	_poly(PackedVector2Array([
		Vector2(_s(24), _s(48)), Vector2(_s(56), _s(48)),
		Vector2(_s(56), _s(53)), Vector2(_s(24), _s(53))
	]), Color.WHITE)

func _face_confused() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(2), 0, _s(4), _s(4.5))
	_poly(_oval(_s(52), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(52), _s(33), _s(4), _s(2.5)), OLD_INK)
	_line(PackedVector2Array([
		Vector2(_s(44), _s(24)), Vector2(_s(60), _s(22))
	]), OLD_INK, _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(28), _s(54)), Vector2(_s(38), _s(56)),
		Vector2(_s(48), _s(52)), Vector2(_s(52), _s(56))
	]), OLD_INK, _s(2.0))

func _face_yawn() -> void:
	_line(PackedVector2Array([
		Vector2(_s(20), _s(30)), Vector2(_s(28), _s(28)), Vector2(_s(36), _s(30))
	]), OLD_INK, _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(30)), Vector2(_s(52), _s(28)), Vector2(_s(60), _s(30))
	]), OLD_INK, _s(2.0))
	_poly(_oval(_s(40), _s(56), _s(10), _s(12)), MOUTH_DARK)
	_poly(_oval(_s(40), _s(52), _s(6), _s(3)), Color.WHITE)

func _face_sassy() -> void:
	_poly(_oval(_s(28), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(30), _s(33), _s(4), _s(2.5)), OLD_INK)
	_poly(_oval(_s(52), _s(32), _s(9), _s(5)), Color.WHITE)
	_poly(_oval(_s(54), _s(33), _s(4), _s(2.5)), OLD_INK)
	_line(PackedVector2Array([
		Vector2(_s(18), _s(26)), Vector2(_s(36), _s(28))
	]), OLD_INK, _s(1.8))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(28)), Vector2(_s(62), _s(26))
	]), OLD_INK, _s(1.8))
	_line(PackedVector2Array([
		Vector2(_s(30), _s(54)), Vector2(_s(42), _s(56)), Vector2(_s(54), _s(50))
	]), OLD_INK, _s(2.2))

func _face_nervous() -> void:
	_eye(_s(28), _s(28), _s(8), _s(9), _s(1), _s(-1), _s(3.5), _s(4))
	_eye(_s(52), _s(28), _s(8), _s(9), _s(-1), _s(-1), _s(3.5), _s(4))
	_poly(_oval(_s(60), _s(22), _s(3), _s(4)), Color(0.4, 0.7, 0.9, 0.5))
	_poly(PackedVector2Array([
		Vector2(_s(22), _s(50)), Vector2(_s(58), _s(50)),
		Vector2(_s(58), _s(60)), Vector2(_s(22), _s(60))
	]), MOUTH_DARK)
	_line(PackedVector2Array([
		Vector2(_s(30), _s(50)), Vector2(_s(30), _s(60))
	]), Color.WHITE, _s(1.5))
	_line(PackedVector2Array([
		Vector2(_s(40), _s(50)), Vector2(_s(40), _s(60))
	]), Color.WHITE, _s(1.5))
	_line(PackedVector2Array([
		Vector2(_s(50), _s(50)), Vector2(_s(50), _s(60))
	]), Color.WHITE, _s(1.5))

func _face_blush() -> void:
	_eye(_s(28), _s(28), _s(8), _s(9), 0, 0, _s(4), _s(4.5))
	_eye(_s(52), _s(28), _s(8), _s(9), 0, 0, _s(4), _s(4.5))
	_poly(_oval(_s(18), _s(42), _s(7), _s(4)), Color(0.9, 0.45, 0.5, 0.3))
	_poly(_oval(_s(62), _s(42), _s(7), _s(4)), Color(0.9, 0.45, 0.5, 0.3))
	_line(_smile(_s(30), _s(50), _s(52), _s(4)), OLD_INK, _s(1.8))

func _face_starry() -> void:
	var star_col: Color = Color(0.95, 0.85, 0.2, 0.9)
	_poly(PackedVector2Array([
		Vector2(_s(28), _s(22)), Vector2(_s(30), _s(28)), Vector2(_s(36), _s(30)),
		Vector2(_s(30), _s(32)), Vector2(_s(28), _s(38)), Vector2(_s(26), _s(32)),
		Vector2(_s(20), _s(30)), Vector2(_s(26), _s(28))
	]), star_col)
	_poly(PackedVector2Array([
		Vector2(_s(52), _s(22)), Vector2(_s(54), _s(28)), Vector2(_s(60), _s(30)),
		Vector2(_s(54), _s(32)), Vector2(_s(52), _s(38)), Vector2(_s(50), _s(32)),
		Vector2(_s(44), _s(30)), Vector2(_s(50), _s(28))
	]), star_col)
	_poly(_oval(_s(40), _s(58), _s(8), _s(9)), MOUTH_DARK)

func _face_grumpy() -> void:
	_eye(_s(28), _s(34), _s(8), _s(8), 0, _s(1), _s(4), _s(4))
	_eye(_s(52), _s(34), _s(8), _s(8), 0, _s(1), _s(4), _s(4))
	_line(PackedVector2Array([
		Vector2(_s(16), _s(22)), Vector2(_s(38), _s(28))
	]), OLD_INK, _s(2.8))
	_line(PackedVector2Array([
		Vector2(_s(64), _s(22)), Vector2(_s(42), _s(28))
	]), OLD_INK, _s(2.8))
	_line(PackedVector2Array([
		Vector2(_s(26), _s(56)), Vector2(_s(34), _s(60)),
		Vector2(_s(46), _s(60)), Vector2(_s(54), _s(56))
	]), OLD_INK, _s(2.2))

func _face_silly() -> void:
	_eye(_s(28), _s(30), _s(9), _s(10), _s(4), _s(1), _s(4), _s(4.5))
	_eye(_s(52), _s(30), _s(9), _s(10), _s(-4), _s(1), _s(4), _s(4.5))
	_line(_smile(_s(24), _s(56), _s(52), _s(6)), OLD_INK, _s(2.0))
	_poly(PackedVector2Array([
		Vector2(_s(33), _s(56)), Vector2(_s(47), _s(56)),
		Vector2(_s(48), _s(66)), Vector2(_s(40), _s(70)), Vector2(_s(32), _s(66))
	]), TONGUE_PINK)

func _face_zen() -> void:
	_line(PackedVector2Array([
		Vector2(_s(20), _s(32)), Vector2(_s(28), _s(28)), Vector2(_s(36), _s(32))
	]), OLD_INK, _s(2.2))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(32)), Vector2(_s(52), _s(28)), Vector2(_s(60), _s(32))
	]), OLD_INK, _s(2.2))
	_line(_smile(_s(30), _s(50), _s(48), _s(4)), OLD_INK, _s(1.8))
	_poly(_oval(_s(18), _s(42), _s(6), _s(3.5)), Color(0.9, 0.45, 0.5, 0.2))
	_poly(_oval(_s(62), _s(42), _s(6), _s(3.5)), Color(0.9, 0.45, 0.5, 0.2))

func _face_gasp() -> void:
	_eye(_s(26), _s(24), _s(11), _s(12), 0, _s(-2), _s(3), _s(3.5))
	_eye(_s(54), _s(24), _s(11), _s(12), 0, _s(-2), _s(3), _s(3.5))
	_line(PackedVector2Array([
		Vector2(_s(18), _s(14)), Vector2(_s(34), _s(16))
	]), OLD_INK, _s(2.0))
	_line(PackedVector2Array([
		Vector2(_s(46), _s(16)), Vector2(_s(62), _s(14))
	]), OLD_INK, _s(2.0))
	_poly(_oval(_s(40), _s(58), _s(10), _s(12)), MOUTH_DARK)
	_poly(_oval(_s(40), _s(53), _s(7), _s(3)), Color.WHITE)

func _face_content() -> void:
	_line(PackedVector2Array([
		Vector2(_s(20), _s(34)), Vector2(_s(28), _s(30)), Vector2(_s(36), _s(34))
	]), OLD_INK, _s(2.2))
	_line(PackedVector2Array([
		Vector2(_s(44), _s(34)), Vector2(_s(52), _s(30)), Vector2(_s(60), _s(34))
	]), OLD_INK, _s(2.2))
	_line(_smile(_s(26), _s(54), _s(50), _s(6)), OLD_INK, _s(2.0))
	_poly(_oval(_s(20), _s(44), _s(5), _s(3)), Color(0.9, 0.45, 0.5, 0.2))
	_poly(_oval(_s(60), _s(44), _s(5), _s(3)), Color(0.9, 0.45, 0.5, 0.2))
