class_name TilemapSpawner extends Node2D

@export var spawn_scenes: Dictionary[String, PackedScene] = {}
@export var spawn_equipment: Dictionary[String, Array] = {}
@export var spawn_probabilities: Dictionary[String, float] = {}

var _spawn_timer := Timer.new()

@onready var _spawned: Array = []

func _on_spawn() -> void:
	pass

func _ready() -> void:
	_spawn_timer.wait_time = 1.0
	_spawn_timer.autostart = true
	_spawn_timer.timeout.connect(_on_spawn)
	add_child(_spawn_timer)

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
		
		_spawned.append(spawned.get_path())
		
func is_spawned_not_exists() -> bool:
	var not_exists = _spawned.all(func(spawned): return not get_tree().current_scene.has_node(spawned))
	if not_exists: _spawned.clear()
	return not_exists

func spawned_count() -> int:
	return _spawned.filter(func(spawned): return get_tree().current_scene.has_node(spawned)).size()
