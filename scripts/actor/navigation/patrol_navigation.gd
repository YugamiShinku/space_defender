class_name ActorPatrolNavigation extends ActorNavigation

func _get_target_position() -> Vector2:
	target_desired_distance = 25.0
	if is_navigation_finished():
		var map_rid = get_navigation_map()
		return NavigationServer2D.map_get_random_point(map_rid, 1, false)
	else:
		return get_final_position() 
		
func _physics_process(delta: float) -> void:
	super._process(delta)
