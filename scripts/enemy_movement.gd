extends CharacterBody2D


@export var target: Node2D
@export var movement_speed: float = 150.0
@export var movement_acceleration: float = 5.0
@export var movement_deceleration: float = 10.0
@export var vision_range: float = 300.0
@export var vision_angle: float = 120.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_rays: Node2D = $VisionRays

var can_see_target: bool = false
var last_target_position: Vector2
var current_direction: Vector2 = Vector2.DOWN

func setup_vision_rays():
	# Создаем лучи для периферийного зрения
	for i in range(-2, 3):
		var new_ray = RayCast2D.new()
		new_ray.name = "VisionRay%d" % i
		new_ray.enabled = true
		new_ray.collide_with_areas = true
		new_ray.collide_with_bodies = true
		new_ray.collision_mask = 1  # Настройте маску согласно вашим слоям
		vision_rays.add_child(new_ray)

func _ready():
	navigation_agent.avoidance_enabled = true
	navigation_agent.radius = 10.0
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 10.0
	navigation_agent.max_speed = movement_speed
	setup_vision_rays()

func update_rotation():
	if self.velocity.length() > 0:
		current_direction = velocity.normalized()
	# Обновляем направление лучей
	for i in range(vision_rays.get_child_count()):
		var ray = vision_rays.get_child(i)
		var angle = deg_to_rad(i * 30)  # Лучи через каждые 30 градусов
		ray.target_position = current_direction.rotated(angle) * vision_range

func rad_to_dir(angle: float) -> float:
	return wrapf(angle, -PI, PI) * 180 / PI

func update_vision():
	if !target: return
	
	can_see_target = false
	var to_target = target.global_position - self.global_position
	var distance = to_target.length()
	
	if distance > vision_range:
		return
	
	var angle_to_target = rad_to_dir(current_direction.angle_to(to_target.normalized()))
	if abs(angle_to_target) > vision_angle / 2:
		return

	var direction = to_target.normalized()
	
	for ray in vision_rays.get_children():
		ray.force_raycast_update()
		if ray.is_colliding():
			can_see_target = true
			last_target_position = target.global_position
			break


func update_navigation():
	if can_see_target:
		navigation_agent.target_position = target.global_position
	elif navigation_agent.is_navigation_finished():
		navigation_agent.target_position = last_target_position

func get_movement_direction() -> Vector2:
	var next_path_position = navigation_agent.get_next_path_position()
	return self.global_position.direction_to(next_path_position)

func move_character(delta):
	var movement_direction = get_movement_direction()
	var target_velocity = movement_direction * movement_speed

	var acceleration_rate = movement_acceleration if movement_direction != Vector2.ZERO else movement_deceleration
	
	self.velocity = self.velocity.lerp(target_velocity, delta * acceleration_rate)

	update_animations(movement_direction)
	move_and_slide()

func _physics_process(delta: float) -> void:
	update_vision()
	update_navigation()
	move_character(delta)
	update_rotation()

func update_animations(direction: Vector2):
	if direction.length() > 0:
		play_walk_animation(direction)
	else:
		play_idle_animation()


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
