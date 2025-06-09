class_name MainMenu extends Control

@export var game_menu: GameMenu
@export var settings_menu: SettingsMenu
@export var quit_menu: QuitMenu
@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

@export var audio_stream: AudioStreamPlayer2D

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func _on_touch_screen_button_play_released() -> void:
	get_tree().paused = false
	game_menu.set_visibility(true)
	settings_menu.set_visibility(false)
	quit_menu.set_visibility(false)
	set_visibility(false)

func _on_touch_screen_button_settings_released() -> void:
	settings_menu.switch_visibility()

func _on_touch_screen_button_quit_released() -> void:
	quit_menu.set_visibility(true)
	settings_menu.set_visibility(false)

func _on_touch_screen_button_play_pressed() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()

func _on_touch_screen_button_settings_pressed() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()

func _on_touch_screen_button_quit_pressed() -> void:
	audio_stream.stream = AudioSources.ERROR
	audio_stream.play()
