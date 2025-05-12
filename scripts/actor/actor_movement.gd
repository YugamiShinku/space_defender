class_name ActorMovement extends Node2D

@export var character_body: CharacterBody2D
@export var speed: float = 150.0
@export var acceleration: float = 5.0
@export var deceleration: float = 10.0

var movement_direction: Vector2 = Vector2.ZERO

func _setup_velocity(delta: float) -> void:
	var rate = acceleration if movement_direction != Vector2.ZERO else deceleration
	character_body.velocity = character_body.velocity.lerp(movement_direction * speed, rate *  delta)

func _physics_process(delta: float) -> void:
	_setup_velocity(delta)
	character_body.move_and_slide()
