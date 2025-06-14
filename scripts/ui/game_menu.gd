class_name GameMenu extends Control

@export var pause_menu: PauseMenu

@export var director: Director

@onready var _health_bar: TextureProgressBar = $"CanvasLayer/TextureProgressBar (Health)"
@onready var _protection_bar: TextureProgressBar = $"CanvasLayer/TextureProgressBar (Protection)"
@onready var _skill_bar: TextureProgressBar = $"CanvasLayer/TextureProgressBar (Skill)"
@onready var _skill_button: TouchScreenButton = $"CanvasLayer/TouchScreenButton (Skill)"
@onready var _segment_count: Label = $"CanvasLayer/Label (SegmentCount)"
@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

@export var audio_stream: AudioStreamPlayer2D

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func _process(delta: float) -> void:
	_health_bar.max_value = director._player_controller.health._health_max
	_protection_bar.max_value = director._player_controller.health._protection_max
	
	_health_bar.value = director._player_controller.health._health_current
	_protection_bar.value = director._player_controller.health._protection_current
	
	_segment_count.text = str("Segment ", director._room_count)
	
	_skill_bar.value = director._player_controller.ability._current
	if director._player_controller.ability._current < 100:
		_skill_bar.visible = true
		_skill_button.visible = false
	else:
		_skill_bar.visible = false
		_skill_button.visible = true

func _on_touch_screen_button_pause_released() -> void:
	audio_stream.stream = AudioSources.BUTTON_PRESSED
	audio_stream.play()
	get_tree().paused = true
	pause_menu.set_visibility(true)
	set_visibility(false)
