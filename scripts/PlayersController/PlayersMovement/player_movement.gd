extends CharacterBody2D


@export var movement_speed: float = 150.0
@export var movement_acceleration: float = 5.0
@export var movement_deceleration: float = 10.0


@onready var sprite_2d = $AnimatedSprite2D 


func get_movement_direction() -> Vector2:
	var movement_direction := Vector2.ZERO
	movement_direction.x = Input.get_axis("move_left", "move_right")
	movement_direction.y = Input.get_axis("move_up", "move_down")
	return movement_direction.normalized()	


func _physics_process(delta: float) -> void:
	var movement_direction = get_movement_direction()
	var target_velocity = movement_direction * movement_speed

	var acceleration_rate = movement_acceleration if movement_direction != Vector2.ZERO else movement_deceleration
	
	self.velocity = self.velocity.lerp(target_velocity, delta * acceleration_rate)

	if movement_direction.length() > 0:
		play_walk_animation(movement_direction)
	else:
		play_idle_animation()

	move_and_slide()

func play_idle_animation():
	sprite_2d.play("idle_front")

func play_walk_animation(direction: Vector2):
	if direction.x > 0:
		if direction.y > 0:
			sprite_2d.play("walk_down_right")
		elif direction.y < 0:
			sprite_2d.play("walk_top_right")
		else:
			sprite_2d.play("walk_right")
	elif direction.x < 0:
		if direction.y > 0:
			sprite_2d.play("walk_down_left")
		elif direction.y < 0:
			sprite_2d.play("walk_top_left")
		else:
			sprite_2d.play("walk_left")
	else:
		if direction.y > 0:
			sprite_2d.play("walk_down")
		elif direction.y < 0:
			sprite_2d.play("walk_top")
