class_name EnemyController extends ActorController

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _update_navigation():
	var target = enemy_detector.get_nearest_target()
	var stop_distance = _get_current_weapon().bullet_max_distance_range.y if _get_current_weapon() else navigation_agent.target_desired_distance 
	if target:
		var target_position = target.global_position
		target_position = target_position - global_position.direction_to(target_position) * stop_distance
		navigation_agent.target_position = target_position

func _setup_movement_direction():
	movement_direction = global_position.direction_to(navigation_agent.get_next_path_position()).normalized()
	
func _physics_process(delta: float) -> void:
	pickup_nearest_weapon()
	
	if enemy_detector.get_nearest_target() && _get_current_weapon():
		var shoot_direction = Vector2.RIGHT.rotated( _get_current_weapon().global_rotation)
		_get_current_weapon().shoot(shoot_direction)

	_update_navigation()
	super._physics_process(delta)
