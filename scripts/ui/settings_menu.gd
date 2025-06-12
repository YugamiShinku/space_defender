class_name SettingsMenu extends Control

@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

@export var pressed_audio: AudioStreamPlayer2D

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func switch_visibility() -> void:
	_canvas_layer.visible = !_canvas_layer.visible

func _ready() -> void:
	AudioServer.set_bus_layout(preload("res://audio/audio_layout.tres"))

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_vibration_value_changed(value: float) -> void:
	Vibration.VIBRATION_STRENGTH = value

func _on_vibration_drag_ended(value_changed: bool) -> void:
	Input.vibrate_handheld(250 * Vibration.VIBRATION_STRENGTH, Vibration.VIBRATION_STRENGTH)

func _on_master_volume_drag_ended(value_changed: bool) -> void:
	pressed_audio.play()
