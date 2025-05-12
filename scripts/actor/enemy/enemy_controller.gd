class_name EnemyController extends Node2D

@onready var movement: ActorMovement = $"ActorMovement"
@onready var health: ActorHealth = $"ActorHealth"
@onready var navigation: ActorNavigation = $"NavigationAgent2D"
@onready var aimer: ActorAimer = $"ActorAimer"
@onready var equipment: ActorEquipment = $"ActorEquipment"
@onready var animator: ActorAnimator = $"AnimationTree"
@onready var aim_detector: ActorDetector = $"Aim Detector"
@onready var weapon_detector: ActorDetector = $"Weapon Detector"
@onready var effector: ActorEffector = $"ActorEffector"

var full_health_color := Color.html("#9bbd62")
var less_health_color := Color.html("#bd6262")

func take_damage(damage):
	var prev_health = health.current_health
	health.take_damage(damage)
	effector.blink_thickness()
	effector.outline_color_lerp(full_health_color, less_health_color, prev_health, health.current_health, health.max_health, 1.0)
	
	if health.is_dead():
		queue_free()

func set_detected(detected: bool) -> void:
	if detected:
		effector.outline_thickness()
		var prev_health = health.current_health
		effector.outline_color_lerp(full_health_color, less_health_color, prev_health, health.current_health, health.max_health, 1.0)
	else:
		effector.outline_thickness()

func _setup_movement_direction():
	if !navigation.is_navigation_finished(): movement.movement_direction = global_position.direction_to(navigation.get_next_path_position())
	else: movement.movement_direction = Vector2.ZERO
	
func _setup_aimer_target_position():
	var aim_nearest_target = aim_detector.get_nearest_target()
	if aim_nearest_target:
		aimer.target_position = aim_nearest_target.global_position - global_position
	else:
		aimer.target_position = movement.movement_direction
	
func _setup_animator_state():
	animator.movement_blend_position = movement.movement_direction
	
func _process(_delta: float) -> void:
	_setup_movement_direction()
	_setup_aimer_target_position()
	_setup_animator_state()
	
	var current_weapon = equipment.get_current_weapon()
	var nearest_weapon = weapon_detector.get_nearest_target()
	if !current_weapon and nearest_weapon:
		equipment.pickup_weapon(nearest_weapon)

	if aim_detector.get_nearest_target() && current_weapon:
		current_weapon.shoot()

func _on_area_2d_hit_box_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage)
