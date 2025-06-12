class_name EnemyController extends Node2D

@onready var movement: ActorMovement = $"ActorMovement"
@onready var health: ActorHealth = $"ActorHealth"
@onready var navigation: TargetNavigation = $"NavigationAgent2D"
@onready var aimer: ActorAimer = $"ActorAimer"
@onready var equipment: ActorEquipment = $"ActorEquipment"
@onready var animator: ActorAnimator = $"AnimationTree"
@onready var aim_detector: ActorDetector = $"Aim Detector"
@onready var weapon_detector: ActorDetector = $"Weapon Detector"
@onready var effector: ActorEffector = $"ActorEffector"

func set_detected(detected: bool) -> void:
	effector.outline_thickness(1.0 if detected else 0.0)

func _setup_movement_direction() -> void:
	if !navigation.is_navigation_finished(): 
		movement._direction = global_position.direction_to(navigation.get_next_path_position())
	else:
		movement._direction = Vector2.ZERO
	
func _setup_aimer_target_position() -> void:
	var aim_nearest_target = aim_detector.get_nearest_target()
	if aim_nearest_target:
		aimer.target_position = aim_nearest_target.global_position - global_position
	else:
		aimer.target_position = movement._direction
	
func _setup_animator_state():
	animator.movement_blend_position = movement._direction
	
func _process(_delta: float) -> void:
	_setup_movement_direction()
	_setup_aimer_target_position()
	_setup_animator_state()
	
	var current_weapon := equipment.get_current_weapon()
	var nearest_weapon := weapon_detector.get_nearest_target()
	if !current_weapon and nearest_weapon:
		equipment.pickup_weapon(nearest_weapon.get_parent())
		
	if aim_detector.get_nearest_target() && current_weapon:
		current_weapon.shoot()

func _on_actor_health_after_take_damage(damage: float) -> void:
	effector.blink_thickness()
	
	if health.is_dead():
		var prob = randf()
		if prob >= 0.0:
			equipment.drop_current_weapon.call_deferred()
		queue_free()
