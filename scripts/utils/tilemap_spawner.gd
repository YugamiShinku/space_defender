class_name TileampSpawner extends Node2D

@export var spawn_scenes: Array[PackedScene]
@export var spawn_probabilities: Array[float]
@export var spawn_count: int = 5

#func _ready() -> void:
	#call_deferred("spawn")

func get_random_scene() -> PackedScene:
	var rand = randf()
	var cumulative = 0.0
	
	for i in spawn_probabilities.size():
		cumulative += spawn_probabilities[i]
		if rand < cumulative:
			return spawn_scenes[i]
	
	return null

func spawn() -> void:
	var map_rid = get_world_2d().navigation_map
	for _i in spawn_count:
		var spawn_position = NavigationServer2D.map_get_random_point(map_rid, 1, false)
		var spawn_scene = get_random_scene()
		var spawned = spawn_scene.instantiate()
		get_tree().current_scene.add_child(spawned)
		spawned.global_position = spawn_position
