class_name TilemapSpawner extends Node2D

@export var spawn_scenes: Dictionary[String, PackedScene] = {}
@export var spawn_equipment: Dictionary[String, Array] = {}
@export var spawn_probabilities: Dictionary[String, float] = {}

func get_random_scene() -> Dictionary:
	var rand = randf()
	var cumulative = 0.0
	
	for key in spawn_probabilities:
		cumulative += spawn_probabilities[key]
		if rand < cumulative:
			return {
				"scene": spawn_scenes[key],
				"equipment": spawn_equipment.get(key, [])
			}
	
	return {"scene": null, "equipment": []}

func spawn(spawn_count: int) -> void:
	var map_rid = get_world_2d().navigation_map
	for _i in spawn_count:
		var spawn_scene = get_random_scene()
		
		var spawn_position = NavigationServer2D.map_get_random_point(map_rid, 1, false)
		var spawned: EnemyController = spawn_scene["scene"].instantiate()
		
		get_tree().current_scene.add_child(spawned)
		spawned.global_position = spawn_position
		
		var weapon_scene = spawn_scene["equipment"].pick_random()
		var weapon = weapon_scene.instantiate()
		get_tree().current_scene.add_child(weapon)
		spawned.equipment.pickup_weapon(weapon)
