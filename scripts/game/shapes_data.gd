extends RefCounted
class_name ShapesData
## Données des 20 formes de pièces disponibles

const SHAPES: Array = [
	# Simples
	[[1]],
	[[1, 1]],
	[[1], [1]],
	# Barres de 3
	[[1, 1, 1]],
	[[1], [1], [1]],
	# Barres de 4
	[[1, 1, 1, 1]],
	[[1], [1], [1], [1]],
	# Barres de 5
	[[1, 1, 1, 1, 1]],
	[[1], [1], [1], [1], [1]],
	# Carré 2x2
	[[1, 1], [1, 1]],
	# Grand carré 3x3
	[[1, 1, 1], [1, 1, 1], [1, 1, 1]],
	# L
	[[1, 1], [1, 0]],
	# L inversé
	[[1, 0], [1, 1]],
	# L miroir
	[[0, 1], [1, 1]],
	# L miroir inversé
	[[1, 1], [0, 1]],
	# Grand L
	[[1, 1, 1], [1, 0, 0]],
	# Grand L inversé
	[[1, 0, 0], [1, 1, 1]],
	# Grand L miroir
	[[1, 1, 1], [0, 0, 1]],
	# T
	[[0, 1, 0], [1, 1, 1]],
	# T inversé
	[[1, 1, 1], [0, 1, 0]],
]

# Couleurs et symboles des blocs
const BLOCK_TYPES: Array = [
	{"color": Color("#c4615e"), "symbol": "✦"},
	{"color": Color("#7a8b3d"), "symbol": "◆"},
	{"color": Color("#7a4878"), "symbol": "●"},
	{"color": Color("#3a4878"), "symbol": "▲"},
	{"color": Color("#a55838"), "symbol": "♦"},
	{"color": Color("#d4af37"), "symbol": "★"},
]

static func get_random_shape() -> Array:
	return SHAPES[randi() % SHAPES.size()]

static func get_random_block_type() -> Dictionary:
	return BLOCK_TYPES[randi() % BLOCK_TYPES.size()]
