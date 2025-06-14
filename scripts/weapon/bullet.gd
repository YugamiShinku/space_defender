class_name Bullet extends Node2D

@export var damage := 10
@export var max_distance_range := Vector2(500, 800)
@export var speed_range := Vector2(500, 700)

var _speed := 500.0
var _direction := Vector2.ZERO
var _max_distance := 750.0
var _distance_traveled := 0.0

func initialize(direction: Vector2) -> void:
	_direction = direction
	_speed = randf_range(speed_range.x, speed_range.y)
	_max_distance = randf_range(max_distance_range.x, max_distance_range.y)
	rotation = direction.angle()

func _physics_process(delta) -> void:
	var movement = _direction * _speed * delta
	position += movement

	_distance_traveled += movement.length()	
	if _distance_traveled >= _max_distance:
		_on_damage(null)

func _on_damage(damaged: Node2D) -> void:
	if damaged:
		if damaged.has_method("take_damage"):
			damaged.take_damage(damage)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	_on_damage(body)

func _on_area_2d_area_entered(area: Area2D) -> void:
	_on_damage(area)
