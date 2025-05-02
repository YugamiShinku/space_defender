class_name ActorAimer extends ActorEquipment

@export var aim_detector: ActorDetector
@export var weapon_rotation_speed: float = 7.5

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	setup_weapon_rotation(delta)

func setup_weapon_rotation(delta: float):
	var target: Vector2
	
	var aim_target = aim_detector.get_nearest_target()
	
	if aim_target: target = aim_target.global_position - global_position
	else: target = movement_direction

	var current_weapon = get_current_weapon()
	
	if target.length() > 0.1 and current_weapon:
		if target.x < 0: current_weapon.scale.y = -1
		elif target.x > 0: current_weapon.scale.y = 1

		current_weapon.global_rotation = lerp_angle(
			current_weapon.global_rotation,
			target.angle(),
			weapon_rotation_speed * delta
		)
