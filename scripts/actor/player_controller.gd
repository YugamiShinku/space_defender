class_name PlayerController extends Node2D

@onready var movement: ActorMovement = $"ActorMovement"
@onready var health: ActorHealth = $"ActorHealth"
@onready var equipment: ActorEquipment = $"ActorEquipment"
@onready var aimer: ActorAimer = $"ActorAimer"
@onready var animator: ActorAnimator = $"AnimationTree"
@onready var aim_detector: ActorDetector = $"Aim Detector"
@onready var weapon_detector: ActorDetector = $"Weapon Detector"
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var camera: Camera2D = $"Camera2D"
@onready var effector: ActorEffector = $"ActorEffector"
@onready var camera_shake: ActorShake = $"ActorShake"

func _setup_movement_direction() -> void:
	movement._direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _setup_aimer_target_position() -> void:
	var current_weapon = equipment.get_current_weapon()
	if current_weapon:
		var aim_nearest_target = aim_detector.get_nearest_target()
		if aim_nearest_target:
			aimer.target_position = aim_nearest_target.global_position - global_position
		else:
			aimer.target_position = movement._direction

func _setup_animator_state() -> void:
	animator.movement_blend_position = movement._direction

func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("equip"):
		var nearest_target = weapon_detector.get_nearest_target()
		if nearest_target:
			equipment.pickup_weapon(nearest_target.get_parent())
		else:
			equipment.switch_to_next_weapon()
		
	# TODO: ABILITIES
	if event.is_action_pressed("ability"):
		pass

func _process(_delta: float) -> void:
	_setup_movement_direction()
	_setup_aimer_target_position()
	_setup_animator_state()
	
	for target in aim_detector.get_targets():
		if target == aim_detector.get_nearest_target():
			if target.get_parent().has_method("set_detected"):
				target.get_parent().set_detected(true)
		else:
			if target.get_parent().has_method("set_detected"):
				target.get_parent().set_detected(false)
	
	var current_weapon: Weapon = equipment.get_current_weapon()
	if Input.is_action_pressed("shoot") && current_weapon && current_weapon._can_shoot:
		var bullets_count := current_weapon.shoot()
		Input.vibrate_handheld(current_weapon.fire_rate * 100 * Vibration.VIBRATION_STRENGTH, clamp(current_weapon.fire_rate * bullets_count, 0.1, 1.0) * Vibration.VIBRATION_STRENGTH)

func _on_actor_health_after_take_damage(damage: float) -> void:
	Input.vibrate_handheld(damage * 100 * Vibration.VIBRATION_STRENGTH, (damage / 2) * Vibration.VIBRATION_STRENGTH)
	effector.blink_thickness()
	camera_shake.shake(damage / 2)

	if health.is_dead():
		get_tree().reload_current_scene()
