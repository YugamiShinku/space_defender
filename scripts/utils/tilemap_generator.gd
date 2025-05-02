class_name TileMapGenerator extends Node2D

@export var tiles: Dictionary[String, Vector2i] = {}
@export var layers: Dictionary[String, TileMapLayer] = {}

@export var corridor_width: int = 3
@export var room_count: int = 5
@export var min_room_size := Vector2i(5, 5)
@export var max_room_size := Vector2i(8, 8)
@export var room_spacing: int = 4

@export var obstacle_groups_per_room_range := Vector2i(1, 3)
@export var obstacles_in_group_range := Vector2i(3, 8)
@export var obstacle_spacing: int = 2

@export var room_generate_directions = [
			Vector2i.LEFT, Vector2i.RIGHT, 
			Vector2i.UP, Vector2i.DOWN,
			Vector2i(-1, -1), Vector2i(1, 1),
			Vector2i(-1, 1), Vector2i(1, -1)
		]

var rooms: Array = []

func _ready() -> void:
	generate_rooms()
	generate_obstacles()
	generate_corridors()

func generate_rooms() -> void:
	while rooms.size() < room_count:
		var base_room = null
		if !rooms.is_empty(): base_room = rooms.pick_random()
		
		var size = Vector2i(
			randi_range(min_room_size.x, max_room_size.x),
			randi_range(min_room_size.y, max_room_size.y)
		)
		var direction = room_generate_directions.pick_random()
		
		var offset = base_room.size * direction + direction * room_spacing if base_room else Vector2i.ZERO
		var pos = base_room.position + offset if base_room else Vector2i.ZERO
		
		var room = Rect2i(pos, size)
			
		if is_room_valid(room):
			rooms.append(room)
			paint_room(room)

func is_room_valid(new_room: Rect2i) -> bool:
	for room in rooms:
		if room.grow(room_spacing).intersects(new_room): return false
	return true

func paint_room(room: Rect2i) -> void:
	paint_room_floor(room)
	paint_room_walls(room)
	
func paint_room_floor(room: Rect2i) -> void:
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			layers["floor"].set_cell(Vector2i(x, y), 0, tiles["floor"])	
	
func paint_room_walls(room: Rect2i) -> void:
	var walls = [
		Rect2i(room.position.x - 1, room.position.y - 1, room.size.x + 2, 1),			# upper
		Rect2i(room.position.x - 1, room.position.y + room.size.y, room.size.x + 2, 1),	# lower
		Rect2i(room.position.x - 1, room.position.y, 1, room.size.y),					# left
		Rect2i(room.position.x + room.size.x, room.position.y, 1, room.size.y)			# right
	]
	
	for wall in walls:
		for x in range(wall.position.x, wall.end.x):
			for y in range(wall.position.y, wall.end.y):
				layers["wall"].set_cell(Vector2i(x, y), 0, tiles["wall"])

func generate_obstacles() -> void:
	for room in rooms:
		var groups_count = randi_range(obstacle_groups_per_room_range.x, obstacle_groups_per_room_range.y)
		for _i in groups_count:
			var group_center = get_random_obstacle_position(room)
			if group_center != Vector2i.ZERO:
				create_obstacle_group(room, group_center)

func get_random_obstacle_position(room: Rect2i) -> Vector2i:
	var attempt = 0
	while attempt < 100:
		var pos = Vector2i(
			randi_range(room.position.x + obstacle_spacing, 
					   room.end.x - obstacle_spacing - 1),
			randi_range(room.position.y + obstacle_spacing, 
					   room.end.y - obstacle_spacing - 1)
		)
		if layers["floor"].get_cell_tile_data(pos):
			return pos
		attempt += 1
	return Vector2i.ZERO

func create_obstacle_group(room: Rect2i, center: Vector2i) -> void:
	var obstacles_count = randi_range(obstacles_in_group_range.x, obstacles_in_group_range.y)
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for _j in obstacles_count:
		var dir = directions[randi() % directions.size()]
		var pos = center + dir * randi_range(1, 3)
		
		if is_valid_obstacle_position(room, pos):
			layers["obstacle"].set_cell(pos, 0, tiles["obstacle"])
			directions.append(dir)

func is_valid_obstacle_position(room: Rect2i, pos: Vector2i) -> bool:
	var inner_rect = Rect2i(
		room.position + Vector2i.ONE * obstacle_spacing,
		room.size - Vector2i.ONE * obstacle_spacing * 2
	)
	return inner_rect.has_point(pos) && layers["floor"].get_cell_tile_data(pos) && !layers["wall"].get_cell_tile_data(pos)

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
	var start = room_a.get_center()
	var end = room_b.get_center()
	create_adaptive_corridor(start, end, room_a, room_b)

func create_adaptive_corridor(start: Vector2i, end: Vector2i, room_a: Rect2i, room_b: Rect2i) -> void:
	var nearest_start = find_nearest_connection_point(start, room_a, end)
	var nearest_end = find_nearest_connection_point(end, room_b, start)
	
	var dx = nearest_end.x - nearest_start.x
	var dy = nearest_end.y - nearest_start.y

	var mid = Vector2i(nearest_start.x, nearest_end.y) if abs(dx) > abs(dy) else Vector2i(nearest_end.x, nearest_start.y)
	create_straight_corridor(nearest_start, mid)
	create_straight_corridor(mid, nearest_end)

func find_nearest_connection_point(center: Vector2i, room: Rect2i, target: Vector2i) -> Vector2i:
	var candidates = [
		Vector2i(room.position.x + room.size.x/2, room.position.y),
		Vector2i(room.position.x + room.size.x/2, room.position.y + room.size.y),
		Vector2i(room.position.x, room.position.y + room.size.y/2),
		Vector2i(room.position.x + room.size.x, room.position.y + room.size.y/2),
		target
	]
	
	var nearest_point = center
	var min_distance = INF
	for point in candidates:
		var dist = point.distance_to(target)
		if dist < min_distance:
			min_distance = dist
			nearest_point = point
	return nearest_point

func create_straight_corridor(start: Vector2i, end: Vector2i) -> void:	
	var dx = end.x - start.x
	var dy = end.y - start.y
	
	var dx_step = 1 if dx > 0 else -1
	for x in range(start.x, end.x + dx_step, dx_step):
		create_corridor_segment(x, start.y, corridor_width)
	
	var dy_step = 1 if dy > 0 else -1
	for y in range(start.y, end.y + dy_step, dy_step):
		create_corridor_segment(end.x, y, corridor_width)

func create_corridor_segment(center_x: int, center_y: int, width: int) -> void:
	var half_width = width / 2
	var area = Rect2i(
		center_x - half_width,
		center_y - half_width,
		width,
		width
	)

	paint_corridor(area)

func paint_corridor(area: Rect2i) -> void:
	var expanded_area = area.grow(1)
	for x in expanded_area.size.x:
		for y in expanded_area.size.y:
			var pos = expanded_area.position + Vector2i(x, y)
			if area.has_point(pos):
				place_floor(pos)
			else:
				place_wall(pos)

func place_floor(pos: Vector2i) -> void:
	if layers["wall"].get_cell_tile_data(pos):
		layers["wall"].erase_cell(pos)
	layers["floor"].set_cell(pos, 0, tiles["floor"])

func place_wall(pos: Vector2i) -> void:
	if !layers["floor"].get_cell_tile_data(pos):
		layers["wall"].set_cell(pos, 0, tiles["wall"])
