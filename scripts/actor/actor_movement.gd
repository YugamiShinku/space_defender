class_name ActorMovement extends CharacterBody2D

@export var movement_speed: float = 150.0
@export var movement_acceleration: float = 5.0
@export var movement_deceleration: float = 10.0

var movement_direction: Vector2 = Vector2.ZERO

func _setup_movement_direction() -> void:
	pass

func _setup_velocity(delta: float) -> void:
	var acceleration_rate = movement_acceleration if movement_direction != Vector2.ZERO else movement_deceleration
	velocity = velocity.lerp(movement_direction * movement_speed, acceleration_rate *  delta)

func _physics_process(delta: float) -> void:
	_setup_movement_direction()
	_setup_velocity(delta)
	move_and_slide()

func is_moving() -> bool:
	return movement_direction.length() > 0
