class_name ActorMovementAimer extends ActorAimer

@export var movement: ActorMovement

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _setup_target_position() -> void:
	var target = detector.get_nearest_target()
	if target:
		target_position = target.global_position - global_position
	else:
		target_position = movement.movement_direction
