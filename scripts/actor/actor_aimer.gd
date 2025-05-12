class_name ActorAimer extends Node2D

@export var rotating: Node2D
@export_range(0.0, 100.0, 0.5) var rotation_speed: float = 7.5

var target_position := Vector2.ZERO

func _physics_process(delta: float) -> void:
	_update_rotation(delta)

func _update_rotation(delta: float):	
	if target_position.length() > 0.1:
		if target_position.x < 0: rotating.scale.y = -1
		elif target_position.x > 0: rotating.scale.y = 1

		rotating.global_rotation = lerp_angle(
			rotating.global_rotation,
			target_position.angle(),
			rotation_speed * delta
		)
