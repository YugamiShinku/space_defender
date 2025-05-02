class_name PatrolController extends NavigationController

func _get_target_position() -> Vector2:
	if navigation_agent.is_navigation_finished():
		var map_rid = get_world_2d().navigation_map
		return NavigationServer2D.map_get_random_point(map_rid, 1, false)
	else:
		return navigation_agent.get_final_position() 
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
