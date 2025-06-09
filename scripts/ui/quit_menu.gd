class_name QuitMenu extends Control

@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

@export var audio_stream: AudioStreamPlayer2D

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func _on_touch_screen_button_yes_released() -> void:
	get_tree().quit()

func _on_touch_screen_button_no_pressed() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()

func _on_touch_screen_button_no_released() -> void:
	set_visibility(false)
