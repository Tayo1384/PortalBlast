extends Node2D

const GOLD_DUST := Color(0.831, 0.686, 0.216, 0.6)
const GOLD_DUST_BRIGHT := Color(0.831, 0.686, 0.216, 0.9)

const EARTHY_COLORS: Array[Color] = [
	Color(0.478, 0.545, 0.239, 0.08),
	Color(0.478, 0.282, 0.471, 0.08),
	Color(0.227, 0.282, 0.471, 0.08),
	Color(0.769, 0.380, 0.369, 0.06),
	Color(0.647, 0.345, 0.220, 0.06),
]

var gold_particles: Array[Dictionary] = []
var bg_shapes: Array[Dictionary] = []
var time_elapsed: float = 0.0

const SCREEN_W := 720.0
const SCREEN_H := 1280.0
const GOLD_COUNT := 30
const SHAPE_COUNT := 14


func _ready() -> void:
	z_index = -1
	_spawn_gold_particles()
	_spawn_bg_shapes()


func _spawn_gold_particles() -> void:
	for i in GOLD_COUNT:
		gold_particles.append(_make_gold_particle(randf() * SCREEN_H))


func _make_gold_particle(start_y: float) -> Dictionary:
	return {
		"x": randf() * SCREEN_W,
		"y": start_y,
		"size": randf_range(1.5, 4.5),
		"speed": randf_range(10.0, 30.0),
		"sway_amp": randf_range(8.0, 30.0),
		"sway_freq": randf_range(0.3, 0.9),
		"phase": randf() * TAU,
		"alpha_base": randf_range(0.3, 0.85),
		"twinkle_speed": randf_range(1.5, 4.0),
	}


func _spawn_bg_shapes() -> void:
	for i in SHAPE_COUNT:
		bg_shapes.append({
			"x": randf() * SCREEN_W,
			"y": randf() * SCREEN_H,
			"radius": randf_range(25.0, 70.0),
			"sides": randi_range(4, 7),
			"color": EARTHY_COLORS[randi() % EARTHY_COLORS.size()],
			"speed": randf_range(5.0, 15.0),
			"rotation_speed": randf_range(0.05, 0.2),
			"sway_amp": randf_range(15.0, 40.0),
			"sway_freq": randf_range(0.15, 0.4),
			"phase": randf() * TAU,
			"angle": randf() * TAU,
		})


func _process(delta: float) -> void:
	time_elapsed += delta

	for p in gold_particles:
		p["y"] -= p["speed"] * delta
		if p["y"] < -10.0:
			var new_p := _make_gold_particle(SCREEN_H + randf_range(10.0, 50.0))
			p.merge(new_p, true)

	for s in bg_shapes:
		s["y"] -= s["speed"] * delta
		s["angle"] += s["rotation_speed"] * delta
		if s["y"] < -s["radius"] * 2:
			s["y"] = SCREEN_H + s["radius"] + randf_range(10.0, 80.0)
			s["x"] = randf() * SCREEN_W

	queue_redraw()


func _draw() -> void:
	_draw_bg_shapes()
	_draw_center_glow()
	_draw_gold_particles()
	_draw_vignette()


func _draw_bg_shapes() -> void:
	for s in bg_shapes:
		var cx: float = s["x"] + sin(time_elapsed * s["sway_freq"] + s["phase"]) * s["sway_amp"]
		var cy: float = s["y"]
		var points := PackedVector2Array()
		var sides: int = s["sides"]
		var radius: float = s["radius"]
		var angle: float = s["angle"]

		for i in sides:
			var a: float = angle + (TAU / sides) * i
			var r: float = radius + sin(a * 2.0 + time_elapsed) * 3.0
			points.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))

		draw_colored_polygon(points, s["color"])


func _draw_gold_particles() -> void:
	for p in gold_particles:
		var cx: float = p["x"] + sin(time_elapsed * p["sway_freq"] + p["phase"]) * p["sway_amp"]
		var cy: float = p["y"]
		var sz: float = p["size"]
		var twinkle: float = (sin(time_elapsed * p["twinkle_speed"] + p["phase"]) + 1.0) * 0.5
		var alpha: float = p["alpha_base"] * (0.4 + twinkle * 0.6)

		var diamond := PackedVector2Array([
			Vector2(cx, cy - sz),
			Vector2(cx + sz * 0.6, cy),
			Vector2(cx, cy + sz),
			Vector2(cx - sz * 0.6, cy),
		])
		draw_colored_polygon(diamond, Color(GOLD_DUST.r, GOLD_DUST.g, GOLD_DUST.b, alpha))

		if sz > 3.0 and twinkle > 0.7:
			var glow_alpha: float = alpha * 0.3
			var glow_sz: float = sz * 2.5
			var glow := PackedVector2Array([
				Vector2(cx, cy - glow_sz),
				Vector2(cx + glow_sz * 0.15, cy),
				Vector2(cx, cy + glow_sz),
				Vector2(cx - glow_sz * 0.15, cy),
			])
			draw_colored_polygon(glow, Color(GOLD_DUST.r, GOLD_DUST.g, GOLD_DUST.b, glow_alpha))


func _draw_center_glow() -> void:
	var cx := SCREEN_W * 0.58
	var cy := SCREEN_H * 0.33
	var max_r := 280.0
	var steps := 10
	var pulse := 0.8 + sin(time_elapsed * 0.5) * 0.2
	for i in steps:
		var t := float(i) / steps
		var r := max_r * (1.0 - t)
		var alpha := t * 0.03 * pulse
		draw_circle(Vector2(cx, cy), r, Color(GOLD_DUST.r, GOLD_DUST.g, GOLD_DUST.b, alpha))


func _draw_vignette() -> void:
	var steps := 8

	# Bottom atmospheric blue gradient
	var gradient_h := 200.0
	for i in steps:
		var t: float = float(i) / steps
		var next_t: float = float(i + 1) / steps
		var alpha: float = lerpf(0.25, 0.0, t)
		var y_start: float = SCREEN_H - gradient_h * (1.0 - t)
		var y_end: float = SCREEN_H - gradient_h * (1.0 - next_t)
		var rect := Rect2(0, y_start, SCREEN_W, y_end - y_start)
		draw_rect(rect, Color(0.227, 0.282, 0.471, alpha))

	# Top edge darkening
	var top_h := 160.0
	for i in steps:
		var t: float = float(i) / steps
		var next_t: float = float(i + 1) / steps
		var y_start: float = top_h * t
		var y_end: float = top_h * next_t
		var alpha: float = lerpf(0.2, 0.0, t)
		draw_rect(Rect2(0, y_start, SCREEN_W, y_end - y_start), Color(0.04, 0.04, 0.06, alpha))
