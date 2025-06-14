class_name PauseMenu extends Control

@export var game_menu: GameMenu
@export var settings_menu: SettingsMenu
@export var quit_menu: QuitMenu

@export var audio_stream: AudioStreamPlayer2D

@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible
	if !visible:
		settings_menu.set_visibility(false)

func _on_touch_screen_button_quit_released() -> void:
	audio_stream.stream = AudioSources.ERROR
	audio_stream.play()
	
	quit_menu.set_visibility(true)

func _on_touch_screen_button_settings_released() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()
	
	settings_menu.switch_visibility()

func _on_touch_screen_button_resume_released() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()
	
	get_tree().paused = false
	game_menu.set_visibility(true)
	set_visibility(false)
