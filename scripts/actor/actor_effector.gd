class_name ActorEffector extends Node2D

@export var effectable: Node2D

var _color_a: Color
var _color_b: Color
var _maximum: float

func blink_thickness(intensity: float = 1.0, duration: float = 0.5) -> void:
	get_tree().create_tween().tween_method(_set_shader_blink_intensity, intensity, 0.0, duration)

func blink_color(color: Color = Color.WHITE, duration: float = 0.5) -> void:
	get_tree().create_tween().tween_method(_set_shader_blink_color, color, 0.0, duration)

func outline_thickness(thickness: float = 1.0, duration: float = 0.5) -> void:
	get_tree().create_tween().tween_method(_set_shader_outline_thickness, thickness, 0.0, duration)
	
func outline_color(color = Color.WHITE, duration: float = 0.5) -> void:
	get_tree().create_tween().tween_method(_set_shader_outline_color, color, 0.0, duration)

func outline_color_lerp(color_a = Color.GREEN, color_b = Color.RED, from: float = 1.0, to: float = 0.0, maximum: float = 1.0, duration: float = 0.5, ) -> void:
	_color_a = color_a
	_color_b = color_b
	_maximum = maximum
	get_tree().create_tween().tween_method(_set_shader_outline_color_lerp, from, to, duration)

func _set_shader_blink_intensity(intensity: float) -> void:
	effectable.material.set_shader_parameter("blink_intensity", intensity)

func _set_shader_blink_color(color: Color) -> void:
	effectable.material.set_shader_parameter("blink_color", color)

func _set_shader_outline_color_lerp(current: float) -> void:
	var ratio = current / _maximum
	var target_color = _color_a.lerp(_color_b, 1.0 - ratio)
	_set_shader_outline_color(target_color)

func _set_shader_outline_color(color: Color) -> void:
	effectable.material.set_shader_parameter("outline_color", color)

func _set_shader_outline_thickness(thickness: float) -> void:
	effectable.material.set_shader_parameter("outline_thickness", thickness)
