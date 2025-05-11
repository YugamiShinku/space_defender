class_name TileMapGenerator extends Node2D

@export var layers: Dictionary[String, TileMapLayer] = {}

@export var compartment_generate_directions = [
			Vector2i.LEFT, 
			#Vector2i.RIGHT, 
			#Vector2i.UP, Vector2i.DOWN,
			#Vector2i(-1, -1), Vector2i(1, 1),
			#Vector2i(-1, 1), Vector2i(1, -1)
		]

@export var compartment_types: Array[Compartment] = []

#func _ready() -> void:
	#generate_rooms()
	##generate_corridors()
#
#func generate_rooms() -> void:
	#var room_count = 8
	#while compartments.size() < room_count:
		#var base_room = null
		#if !compartments.is_empty(): base_room = compartments.pick_random()
		#
		#var direction = room_generate_directions.pick_random()
#
		#var room_spacing = 4
		#var offset = base_room.size * direction + direction * room_spacing if base_room else Vector2i.ZERO
		#var pos = Vector2i(base_room.position.x, base_room.position.y) + offset if base_room else Vector2i.ZERO
		#var size = Vector2i(12, 12)
		#var compartment = Rect2i(pos, size)
#
		#if is_compartment_valid(compartment, room_spacing):
			#compartments.append(compartment)
			#compartment_types[0].generate(pos)
#
#func is_compartment_valid(new_room: Rect2i, room_spacing: int) -> bool:
	##for compartment in compartments:
	##	if compartment.grow(room_spacing).intersects(new_room): return false
	#return true

#func generate_corridors() -> void:
	#var connections = []
	#for i in compartments.size():
		#for j in range(i + 1, compartments.size()):
			#var distance = compartments[i].get_center().distance_to(compartments[j].get_center())
			#connections.append({ "rooms": [i, j], "distance": distance })
	#
	#var sorter = func(a, b): return a["distance"] < b["distance"]
	#connections.sort_custom(sorter)
	#
	#var parent = []
	#parent.resize(compartments.size())
	#for i in compartments.size(): 
		#parent[i] = i
	#
	#var find = func(u: int, p: Array):
		#while p[u] != u: 
			#p[u] = p[p[u]]
			#u = p[u]
		#return u
	#
	#for connection in connections:
		#var u = find.call(connection["rooms"][0], parent)
		#var v = find.call(connection["rooms"][1], parent)
		#if u != v:
			#parent[u] = v
			##connect_rooms(compartments[connection["rooms"][0]], compartments[connection["rooms"][1]])
