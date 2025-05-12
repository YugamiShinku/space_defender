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

var camera_shake_intensity: float = 2.5

var _camera_shake_noise: FastNoiseLite

func _ready() -> void:
	_camera_shake_noise = FastNoiseLite.new()

func _set_camera_shake(intensity: float) -> void:
	if camera:
		var camera_offset = _camera_shake_noise.get_noise_1d(randi()) * intensity
		camera.offset.x = camera_offset
		camera.offset.y = camera_offset

func take_damage(damage):
	health.take_damage(damage)
	effector.blink_thickness()

	# TODO: ON DEAD	
	#if health.is_dead():
		#queue_free()

func _set_blink_intensity(intensity: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", intensity)

func _setup_movement_direction():
	movement.movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _setup_aimer_target_position():
	var aim_nearest_target = aim_detector.get_nearest_target()
	if aim_nearest_target:
		aimer.target_position = aim_nearest_target.global_position - global_position
	else:
		aimer.target_position = movement.movement_direction

func _setup_animator_state():
	animator.movement_blend_position = movement.movement_direction

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		var current_weapon = equipment.get_current_weapon()
		if current_weapon: current_weapon.reload()
	
	if event.is_action_pressed("equip"):
		var nearest_weapon = weapon_detector.get_nearest_target()
		if nearest_weapon:
			equipment.pickup_weapon(nearest_weapon)
		
	if event.is_action_pressed("drop"):
		equipment.drop_current_weapon()
		
	if event.is_action_pressed("switch"):
		equipment.switch_to_next_weapon()

func _process(_delta: float) -> void:
	_setup_movement_direction()
	_setup_aimer_target_position()
	_setup_animator_state()
	
	for target in aim_detector.get_targets():
		if target == aim_detector.get_nearest_target():
			if target.has_method("set_detected"):
				target.set_detected(true)
		else:
			if target.has_method("set_detected"):
				target.set_detected(false)
	
	var current_weapon = equipment.get_current_weapon()
	if Input.is_action_pressed("shoot") && current_weapon:
		current_weapon.shoot()


func _on_area_2d_hit_box_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage)
