class_name TileMapGenerator extends Node2D

@export var tiles: Dictionary[String, Vector2i] = {}
@export var layers: Dictionary[String, TileMapLayer] = {}

@export var corridor_width := 3
@export var room_count_range := Vector2i(4, 8)
@export var min_room_size_range := Vector2i(12, 12)
@export var max_room_size_range := Vector2i(16, 16)
@export var room_spacing_range := Vector2i(4, 8)

var rooms: Array[Rect2i] = []

func generate_next_room() -> Rect2i:
	var previous_room = rooms.back()
	var size = Vector2i(
		randi_range(min_room_size_range.x, max_room_size_range.x),
		randi_range(min_room_size_range.y, max_room_size_range.y)
	)
	var direction = [
			Vector2i.LEFT, Vector2i.RIGHT, 
			Vector2i.UP, Vector2i.DOWN,
	].pick_random()
		
	var room_spacing = randi_range(room_spacing_range.x, room_spacing_range.y)
	var offset = previous_room.size * direction + direction * room_spacing if previous_room else Vector2i.ZERO
	var pos: Vector2i = previous_room.position + offset if previous_room else Vector2i(0 - size.x / 2, 0 - size.y / 2)
		
	var room = Rect2i(pos, size)

	var painted_room = paint_room(room)
	rooms.append(painted_room)
	generate_corridors()
	
	return room

func destroy_previous_room() -> void:
	if rooms.size() > 1:
		var previous_room = rooms.pop_front()
		if previous_room:
			erase_room(previous_room)

func erase_room(room: Rect2i) -> void:
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			var iso_pos = grid_to_isometric(Vector2i(x, y))
			layers["floor"].erase_cell(iso_pos)

func paint_room(room: Rect2i) -> Rect2i:
	paint_room_floor(room)
	return paint_room_walls(room)
	
func paint_room_floor(room: Rect2i) -> void:
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			var iso_pos = grid_to_isometric(Vector2i(x, y))
			layers["floor"].set_cell(iso_pos, 0, tiles["floor"])
	
func paint_room_walls(room: Rect2i) -> Rect2i:
	var room_grow := room.grow(1)
	for x in range(room_grow.position.x, room_grow.end.x):
		for y in range(room_grow.position.y, room_grow.end.y):
			var pos = Vector2i(x, y)
			if !room.has_point(pos) and room_grow.has_point(pos):
				var iso_pos = grid_to_isometric(pos)
				layers["wall"].set_cell(iso_pos, 0, tiles["wall"])
	return room_grow

func grid_to_isometric(grid_pos: Vector2i) -> Vector2i:
	var x_diff = grid_pos.y - grid_pos.x
	return Vector2i(int(floor(x_diff / 2.0)), grid_pos.x + grid_pos.y)

func generate_corridors() -> void:
	var connections = []
	for i in rooms.size():
		for j in range(i + 1, rooms.size()):
			var distance = rooms[i].get_center().distance_to(rooms[j].get_center())
			connections.append({ "rooms": [i, j], "distance": distance })
	
	var sorter = func(a, b): return a["distance"] < b["distance"]
	connections.sort_custom(sorter)
	
	var parent = []
	parent.resize(rooms.size())
	for i in rooms.size(): 
		parent[i] = i
	
	var find = func(u: int, p: Array):
		while p[u] != u: 
			p[u] = p[p[u]]
			u = p[u]
		return u
	
	for connection in connections:
		var u = find.call(connection["rooms"][0], parent)
		var v = find.call(connection["rooms"][1], parent)
		if u != v:
			parent[u] = v
			connect_rooms(rooms[connection["rooms"][0]], rooms[connection["rooms"][1]])

func connect_rooms(room_a: Rect2i, room_b: Rect2i) -> void:
	# Выбираем случайные точки на границах комнат
	var start_point = room_a.get_center()
	var end_point = room_b.get_center()
	
	# Создаем прямой коридор между точками
	create_straight_corridor(start_point, end_point)

func create_straight_corridor(start: Vector2i, end: Vector2i) -> void:
	# Определяем направление коридора
	var dx = sign(end.x - start.x)
	var dy = sign(end.y - start.y)
	
	# Создаем горизонтальную часть
	if dx != 0:
		for x in range(start.x, end.x + dx, dx):
			create_corridor_segment(x, start.y, corridor_width)
	
	# Создаем вертикальную часть
	if dy != 0:
		for y in range(start.y, end.y + dy, dy):
			create_corridor_segment(end.x, y, corridor_width)

func create_corridor_segment(center_x: int, center_y: int, width: int) -> void:
	var half_width = width / 2
	for x_offset in range(-half_width, half_width + 1):
		for y_offset in range(-half_width, half_width + 1):
			var pos = Vector2i(center_x + x_offset, center_y + y_offset)
			place_floor(pos)
			
	# Затем добавляем стены вокруг коридора
	var wall_thickness = 1
	for i in range(-half_width - wall_thickness, half_width + wall_thickness + 1):
		for j in range(-half_width - wall_thickness, half_width + wall_thickness + 1):
			# Пропускаем внутреннюю часть коридора
			if abs(i) <= half_width && abs(j) <= half_width:
				continue
				
			var pos = Vector2i(center_x + i, center_y + j)
			place_wall(pos)

func place_floor(pos: Vector2i) -> void:
	var iso_pos = grid_to_isometric(pos)
	if layers["wall"].get_cell_source_id(iso_pos) != -1:
		layers["wall"].erase_cell(iso_pos)
	layers["floor"].set_cell(iso_pos, 0, tiles["floor"])

func place_wall(pos: Vector2i) -> void:
	var iso_pos = grid_to_isometric(pos)
	if layers["floor"].get_cell_source_id(iso_pos) == -1:
		layers["wall"].set_cell(iso_pos, 0, tiles["wall"])
