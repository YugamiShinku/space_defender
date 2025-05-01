class_name Bullet extends Node2D

var damage: int = 10
var speed: float = 500.0
var direction: Vector2 = Vector2.ZERO
var max_distance: float = 750.0

var _distance_traveled: float = 0.0

func initialize(new_damage: int, new_direction: Vector2, new_speed: float, new_max_distance: float) -> void:
	damage = new_damage
	speed = new_speed
	direction = new_direction
	max_distance = new_max_distance
	rotation = new_direction.angle()

func _physics_process(delta) -> void:
	var movement = direction * speed * delta
	position += movement
	_distance_traveled += movement.length()
	
	if _distance_traveled >= max_distance:
		_destroy()

func _destroy() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_destroy()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	_destroy()
