class_name EnemyMouseController extends EnemyController

func _get_target_position() -> Vector2:
	return get_global_mouse_position()
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
