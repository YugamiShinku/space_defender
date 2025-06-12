class_name ActorAimer extends Node2D

@export var rotatables: Array[Node2D]
@export_range(0.0, 100.0, 0.5) var rotation_speed := 7.5

var target_position := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if target_position.length() > 0.1:
		for rotatable in rotatables:
			if target_position.x < 0: rotatable.scale.y = -1
			elif target_position.x > 0: rotatable.scale.y = 1

			rotatable.global_rotation = lerp_angle(
				rotatable.global_rotation,
				target_position.angle(),
				rotation_speed * delta
			)
