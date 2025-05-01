class_name ActorAnimator extends AnimationTree

@export var actor_movement: ActorMovement

func _process(_delta: float) -> void:
	if actor_movement.is_moving():
		set("parameters/walk/blend_position", actor_movement.movement_direction)
		set("parameters/conditions/is_walking", true)
		set("parameters/conditions/is_idle", false)
	else:
		set("parameters/conditions/is_walking", false)
		set("parameters/conditions/is_idle", true)
