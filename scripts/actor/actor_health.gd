class_name ActorHealth extends Node2D

@export var full_health_color := Color.GREEN
@export var less_health_color := Color.RED
@export_range(0.0, 1000.0, 1.0) var health: float = 100.0
@export var sprite: AnimatedSprite2D
@export var camera: Camera2D
@export_range(0.0, 10.0, 0.5) var camera_shake_intensity: float = 2.5
@export var particles: GPUParticles2D

var _camera_shake_noise: FastNoiseLite

func _ready() -> void:
	_camera_shake_noise = FastNoiseLite.new()
	
func _camera_shake(intensity: float) -> void:
	if camera:
		var camera_offset = _camera_shake_noise.get_noise_1d(Time.get_ticks_msec()) * intensity
		camera.offset.x = camera_offset
		camera.offset.y = camera_offset

func set_detected(detected: bool) -> void:
	print("detected")
	var outline_tween = get_tree().create_tween()
	if detected:
		outline_tween.tween_method(set_shader_outline_thickness, 1.0, 0.0, 0.5)	
		set_shader_outline_color_lerp(health)
	else:
		outline_tween.tween_method(set_shader_outline_thickness, 0.0, 1.0, 0.5)	

func set_shader_outline_color_lerp(current_health: float) -> void:
	var health_ratio = current_health / 1000.0
	var target_color = full_health_color.lerp(less_health_color, 1.0 - health_ratio)
	sprite.material.set_shader_parameter("outline_color", target_color)

func set_shader_outline_thickness(outline_thickness: float) -> void:
	sprite.material.set_shader_parameter("outline_thickness", outline_thickness)

func take_damage(damage):
	print("({}) health: {}", get_parent().name, health)
	var prev_health = health
	health -= damage
	var blink_tween = get_tree().create_tween()
	blink_tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)
	shake_camera(camera_shake_intensity)
	var color_tween = get_tree().create_tween()
	color_tween.tween_method(set_shader_outline_color_lerp, prev_health, health, 1.0)
	
	#particles.restart()
	#particles.emitting = true
	# TODO: Apply Direction to particles
	
	if is_dead():
		get_parent().queue_free()

func shake_camera(intensity: float) -> void:
	var shake_tween = get_tree().create_tween()
	shake_tween.tween_method(_camera_shake, intensity, 1.0, 0.5)

func set_shader_blink_intensity(intensity: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", intensity)

func is_dead() -> bool:
	return health <= 0

func _on_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage)
