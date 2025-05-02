class_name TargetController extends NavigationController

func _get_target_position() -> Vector2:
	navigation_agent.target_desired_distance = 10.0
	var target = aim_detector.get_nearest_target()
	if target:
		navigation_agent.target_desired_distance = 100.0
		return target.global_position
	return navigation_agent.get_final_position()
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
