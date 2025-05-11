@tool
class_name Compartment extends Node2D

@export var generated = false : set = _generate_in_editor
@export var cleared = false : set = _clear_in_editor
@export var cleared_all = false : set = _clear_all_in_editor

@export var tiles: Dictionary[String, Vector2i] = {}
@export var layers: Dictionary[String, TileMapLayer] = {}

@export var min_size: Vector2i = Vector2i(12, 12)
@export var max_size: Vector2i = Vector2i(16, 16)

@export var next: Array[Compartment] = []

var rect: Rect2i

func generate(coords: Vector2i) -> void:
	rect = _get_rect(coords)
	_paint_floor()
	_paint_walls()

func _generate_in_editor(_generated: bool = false):
	_clear_in_editor()
	generate(Vector2i(global_position.x / layers["floor"].tile_set.tile_size.x, global_position.y / layers["floor"].tile_set.tile_size.y))

func _clear_in_editor(_cleared: bool = false) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			for layer in layers.values():
				layer.erase_cell(Vector2i(x, y))

func _clear_all_in_editor(_cleader: bool = false) -> void:
	for layer in layers.values():
		layer.clear()

func _get_rect(coords: Vector2i) -> Rect2i:
	var size = Vector2i(
		randi_range(min_size.x, max_size.x),
		randi_range(min_size.y, max_size.y)
	)
	var pos = Vector2i(
		coords.x - size.x / 2,
		coords.y - size.y / 2
	)
	return Rect2i(pos, size)

func _paint_floor() -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			layers["floor"].set_cell(Vector2i(x, y), 0, tiles["floor"])

func _paint_walls() -> void:
	var extended_rect = rect.grow(1)
	for x in range(extended_rect.position.x, extended_rect.end.x):
		for y in range(extended_rect.position.y, extended_rect.end.y):
			var point = Vector2i(x, y)
			if !rect.has_point(point):
				layers["wall"].set_cell(point, 0, tiles["wall"])
	rect = extended_rect
