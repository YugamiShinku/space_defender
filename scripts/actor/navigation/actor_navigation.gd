class_name ActorNavigation extends NavigationAgent2D

func _get_target_position() -> Vector2:
	return Vector2.ZERO

func _setup_navigation() -> void:
	if is_navigation_finished():
		target_position = _get_target_position()
		return
	
func _process(_delta: float) -> void:	
	_setup_navigation()
