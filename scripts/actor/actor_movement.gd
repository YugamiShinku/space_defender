class_name ActorMovement extends Node2D

@export var character_body: CharacterBody2D
@export var speed := 150.0
@export var acceleration := 5.0
@export var deceleration := 10.0

var _direction: Vector2 = Vector2.ZERO

func _setup_velocity(delta: float) -> void:
	var rate = acceleration if _direction != Vector2.ZERO else deceleration
	character_body.velocity = character_body.velocity.lerp(_direction * speed, rate *  delta)

func _physics_process(delta: float) -> void:
	_setup_velocity(delta)
	character_body.move_and_slide()
