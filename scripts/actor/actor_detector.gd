class_name ActorDetector extends Area2D

@export var ray_cast: RayCast2D
@export var area_exceptions: Array[Area2D] = []
@export var body_exceptions: Array[CollisionObject2D] = []

var _targets: Array[Node2D] = []

func _ready() -> void:
	for body in body_exceptions:
		ray_cast.add_exception(body)

func _is_target_acceptable(target: Node2D) -> bool:
	ray_cast.target_position = ray_cast.to_local(target.global_position)
	ray_cast.force_raycast_update()
	return !ray_cast.is_colliding()	

func _on_area_entered(area: Area2D) -> void:
	if area in area_exceptions: return
	_targets.append(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	_targets.erase(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	_targets.append(body)

func _on_body_exited(body: Node2D) -> void:
	_targets.erase(body)
	
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
