class_name ActorAimer extends Node2D

@export var detector: ActorDetector
@export var rotating: Node2D
@export var rotation_speed: float = 7.5

var target_position := Vector2.ZERO

func _process(_delta: float) -> void:
	_setup_target_position()

func _physics_process(delta: float) -> void:
	_setup_rotation(delta)

func _setup_target_position() -> void:
	var target = detector.get_nearest_target()
	if !target: return
	target_position = target.global_position - global_position	

func _setup_rotation(delta: float):	
	if target_position.length() > 0.1:
		if target_position.x < 0: rotating.scale.y = -1
		elif target_position.x > 0: rotating.scale.y = 1

		rotating.global_rotation = lerp_angle(
			rotating.global_rotation,
			target_position.angle(),
			rotation_speed * delta
		)
