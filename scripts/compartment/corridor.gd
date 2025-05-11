@tool
class_name Corridor extends Node2D

@export var generated = false : set = _generate_in_editor
@export var cleared = false : set = _clear_in_editor
@export var cleared_all = false : set = _clear_all_in_editor

@export var index_start: int = -1
@export var index_end: int = -1

@export var tiles: Dictionary[String, Vector2i] = {}
@export var layers: Dictionary[String, TileMapLayer] = {}

@export var width_range := Vector2i(3, 3)

@export var compartment_a: Compartment
@export var compartment_b: Compartment

var rects: Array[Rect2i] = []

func generate() -> void:
	_clear_in_editor()
	connect_rooms(compartment_a.rect, compartment_b.rect)

func _generate_in_editor(_generated: bool = false):
	_clear_in_editor()
	compartment_a._generate_in_editor()
	compartment_b._generate_in_editor()
	generate()

func _clear_in_editor(_cleared: bool = false) -> void:
	for rect in rects:
		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				for layer in layers.values():
					layer.erase_cell(Vector2i(x, y))
	rects.clear()

func _clear_all_in_editor(_cleader: bool = false) -> void:
	for layer in layers.values():
		layer.clear()
	rects.clear()

func connect_rooms(room_a: Rect2i, room_b: Rect2i) -> void:
	var corridor_width = randi_range(width_range.x, width_range.y)
	var start_points = get_connection_points(room_a, room_b, corridor_width)
	var end_points = get_connection_points(room_b, room_a, corridor_width)
	print(start_points.size())
	print(end_points.size())
	
	var start = start_points[index_start] if index_start != -1 else start_points.pick_random()
	var end = end_points[index_end] if index_end != -1 else end_points.pick_random()
	create_adaptive_corridor(start, end, corridor_width)

func get_connection_points(room: Rect2i, target_room: Rect2i, corridor_width: int) -> Array[Vector2i]:
	var buffer = corridor_width / 2 + 1
	var room_center = room.get_center()
	var target_center = target_room.get_center()
	var points: Array[Vector2i] = []
	
	# Определяем преобладающее направление
	var dx = target_center.x - room_center.x
	var dy = target_center.y - room_center.y
	var horizontal_first = abs(dx) > abs(dy)
	
	# Генерируем точки только для оптимальных сторон
	if dx > 0:
		# Правая стенка
		var y_min = room.position.y + buffer
		var y_max = room.end.y - buffer - 1
		for y in range(y_min, y_max + 1):
			points.append(Vector2i(room.end.x - 1, y))
	else:
		# Левая стенка
		var y_min = room.position.y + buffer
		var y_max = room.end.y - buffer - 1
		for y in range(y_min, y_max + 1):
			points.append(Vector2i(room.position.x, y))
	if dy > 0:
		# Нижняя стенка
		var x_min = room.position.x + buffer
		var x_max = room.end.x - buffer - 1
		for x in range(x_min, x_max + 1):
			points.append(Vector2i(x, room.end.y - 1))
	else:
		# Верхняя стенка
		var x_min = room.position.x + buffer
		var x_max = room.end.x - buffer - 1
		for x in range(x_min, x_max + 1):
			points.append(Vector2i(x, room.position.y))
	
	return points

func create_adaptive_corridor(start: Vector2i, end: Vector2i, corridor_width: int) -> void:
	var dx = end.x - start.x
	var dy = end.y - start.y
	var mid = Vector2i(start.x, end.y) if abs(dx) > abs(dy) else Vector2i(end.x, start.y)
	create_straight_corridor(start, end, corridor_width)
	#create_straight_corridor(mid, end, corridor_width)

func create_straight_corridor(start: Vector2i, end: Vector2i, corridor_width: int) -> void:    
	var rect = Rect2i(start, Vector2i(abs(start.x - end.x), abs(start.y - end.y)))
	_paint_floor(rect)
	_paint_walls(rect)

func _paint_walls(rect: Rect2i) -> void:
	var extended_rect = rect.grow(1)
	for x in range(extended_rect.position.x, extended_rect.end.x):
		for y in range(extended_rect.position.y, extended_rect.end.y):
			var point = Vector2i(x, y)
			if !rect.has_point(point):
				layers["wall"].set_cell(point, 0, tiles["wall"])

func _paint_floor(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			layers["floor"].set_cell(Vector2i(x, y), 0, tiles["floor"])
			
	rects.append(rect)
