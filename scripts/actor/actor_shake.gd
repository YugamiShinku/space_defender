class_name ActorShake extends Node2D

@export var shakable: Node2D

@onready var _shake_noise := FastNoiseLite.new()

func shake(intensity: float = 1.0, duration: float = 1.0) -> void:
	get_tree().create_tween().tween_method(_set_shake, intensity, 1.0, duration)

func _set_shake(intensity: float) -> void:
	var offset = _shake_noise.get_noise_1d(randi()) * intensity
	shakable.offset.x = offset
	shakable.offset.y = offset
