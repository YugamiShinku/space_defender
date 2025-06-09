class_name ActorPatrolTargetNavigation extends ActorNavigation

@export var detector: ActorDetector

func _get_target_position() -> Vector2:
	target_desired_distance = 10.0
	var nearest_target = detector.get_nearest_target()
	if nearest_target:
		target_desired_distance = 100.0
		return nearest_target.global_position

	if is_navigation_finished() and !nearest_target:
		var map_rid = get_navigation_map()
		return NavigationServer2D.map_get_random_point(map_rid, 1, false)
	return get_final_position()
		
func _process(delta: float) -> void:
	super._process(delta)
