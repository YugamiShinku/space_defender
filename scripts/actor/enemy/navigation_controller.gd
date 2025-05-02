class_name NavigationController extends ActorController

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _get_target_position() -> Vector2:
	return Vector2.ZERO

func _update_navigation() -> void:
	navigation_agent.target_position = _get_target_position()
	if navigation_agent.is_navigation_finished():
		return
		
func _setup_movement_direction():
	if !navigation_agent.is_navigation_finished(): movement_direction = global_position.direction_to(navigation_agent.get_next_path_position())
	else: movement_direction = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var current_weapon = get_current_weapon()
	if aim_detector.get_nearest_target() && current_weapon:
		current_weapon.shoot(Vector2.RIGHT.rotated(current_weapon.global_rotation))

	_update_navigation()
