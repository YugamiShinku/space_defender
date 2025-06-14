class_name SettingsMenu extends Control

@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"
@onready var master_volume: HSlider = $CanvasLayer/MasterVolume
@onready var music_volume: HSlider = $CanvasLayer/MusicVolume
@onready var effects_volume: HSlider = $CanvasLayer/EffectsVolume
@onready var vibration: HSlider = $CanvasLayer/Vibration

@export var pressed_audio: AudioStreamPlayer2D

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func switch_visibility() -> void:
	_canvas_layer.visible = !_canvas_layer.visible

func _ready() -> void:
	AudioServer.set_bus_layout(preload("res://audio/audio_layout.tres"))
	var load_data := SaveLoad.load_data()
	if load_data:
		master_volume.value = load_data._master_sound
		AudioServer.set_bus_volume_db(0, linear_to_db(load_data._master_sound))
		music_volume.value = load_data._music_sound		
		AudioServer.set_bus_volume_db(1, linear_to_db(load_data._music_sound))
		effects_volume.value = load_data._vfx_sound
		AudioServer.set_bus_volume_db(2, linear_to_db(load_data._vfx_sound))
		vibration.value = load_data._vibration

func _on_volume_value_changed(value: float) -> void:
	SaveLoad._save_data._master_sound = value
	SaveLoad.save(SaveLoad._save_data)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_volume_value_changed(value: float) -> void:
	SaveLoad._save_data._music_sound = value
	SaveLoad.save(SaveLoad._save_data)
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_effects_volume_value_changed(value: float) -> void:
	SaveLoad._save_data._vfx_sound = value
	SaveLoad.save(SaveLoad._save_data)
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_vibration_value_changed(value: float) -> void:
	SaveLoad._save_data._vibration = value
	SaveLoad.save(SaveLoad._save_data)

func _on_vibration_drag_ended(value_changed: bool) -> void:
	Input.vibrate_handheld(250 * SaveLoad._save_data._vibration, SaveLoad._save_data._vibration)

func _on_master_volume_drag_ended(value_changed: bool) -> void:
	pressed_audio.play()
