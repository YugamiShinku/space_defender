class_name ActorDetector extends Area2D

@export_flags_2d_physics var ray_cast_collision_mask: int = 1
@export var area_exceptions: Array[Area2D] = []
@export var body_exceptions: Array[CollisionObject2D] = []
@export var group_exceptions: Array[StringName] = []

@onready var _ray_cast := RayCast2D.new()

var _targets: Array[Node2D] = []
	
func get_targets() -> Array[Node2D]:
	return _targets.filter(_is_target_acceptable)
	
func get_nearest_target() -> Node2D:
	var nearest_target: Node2D = null
	var min_distance: float = INF
	
	for target in get_targets():
		var distance = global_position.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_target = target
	return nearest_target

func _ready() -> void:
	_ray_cast.collision_mask = ray_cast_collision_mask
	_ray_cast.target_position = Vector2.ZERO
	_ray_cast.collide_with_areas = true
	for body in body_exceptions:
		_ray_cast.add_exception(body)
	add_child(_ray_cast)	

func _is_target_acceptable(target: Node2D) -> bool:
	_ray_cast.target_position = _ray_cast.to_local(target.global_position)
	_ray_cast.force_raycast_update()
	return !_ray_cast.is_colliding()	

func _is_area_excepted(area: Area2D) -> bool:
	return area in area_exceptions

func _is_any_group_excepted(groups: Array[StringName]) -> bool:
	return groups.any(func(group): return group in group_exceptions)

func _on_area_entered(area: Area2D) -> void:
	if _is_area_excepted(area): return
	if _is_any_group_excepted(area.get_groups()): return
	_targets.append(area)

func _on_area_exited(area: Area2D) -> void:
	_targets.erase(area)

func _on_body_entered(body: Node2D) -> void:
	if _is_any_group_excepted(body.get_groups()): return
	_targets.append(body)

func _on_body_exited(body: Node2D) -> void:
	_targets.erase(body)
