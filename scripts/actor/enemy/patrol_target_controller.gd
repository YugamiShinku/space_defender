class_name PatrolTargetController extends NavigationController

func _get_target_position() -> Vector2:
	navigation_agent.target_desired_distance = 10.0
	var target = aim_detector.get_nearest_target()
	if target:
		navigation_agent.target_desired_distance = 100.0
		return target.global_position

	if navigation_agent.is_navigation_finished() and !target:
		var map_rid = get_world_2d().navigation_map
		return NavigationServer2D.map_get_random_point(map_rid, 1, false)
	
	return navigation_agent.get_final_position()
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
