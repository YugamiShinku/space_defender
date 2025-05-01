class_name EnemyController extends ActorController

@export var target: Node2D
@export var vision_range: float = 300.0
@export var vision_angle: float = 120.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_rays: Node2D = $VisionRays

var can_see_target: bool = false
var last_target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO

func setup_vision_rays():
	# Создаем лучи для периферийного зрения
	for i in range(-2, 3):
		var new_ray = RayCast2D.new()
		new_ray.name = "VisionRay%d" % i
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
	can_see_target = false
	var to_target = target.global_position - self.global_position
	var distance = to_target.length()
	
	if distance > vision_range:
		return
	
	var angle_to_target = rad_to_dir(current_direction.angle_to(to_target.normalized()))
	if abs(angle_to_target) > vision_angle / 2:
		return
	
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

func _setup_movement_direction():
	movement_direction = global_position.direction_to(navigation_agent.get_next_path_position()).normalized()

func _physics_process(delta: float) -> void:
	pickup_nearest_weapon()
	if !enemy_detector.targets.is_empty() && _get_current_weapon():
		if  _get_current_weapon().has_method("shoot"):
			var shoot_direction = Vector2.RIGHT.rotated( _get_current_weapon().global_rotation)
			_get_current_weapon().shoot(shoot_direction)
		
	
	update_vision()
	update_navigation()
	super._physics_process(delta)
	update_rotation()
