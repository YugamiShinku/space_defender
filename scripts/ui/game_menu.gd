class_name GameMenu extends Control

@export var pause_menu: PauseMenu

@export var player_controller: PlayerController

@onready var _health_bar: TextureProgressBar = $"CanvasLayer/TextureProgressBar (Health)"
@onready var _protection_bar: TextureProgressBar = $"CanvasLayer/TextureProgressBar (Protection)"
@onready var _canvas_layer: CanvasLayer = $"CanvasLayer"

func set_visibility(visible: bool) -> void:
	_canvas_layer.visible = visible

func _process(delta: float) -> void:
	_health_bar.max_value = player_controller.health._health_max
	_protection_bar.max_value = player_controller.health._protection_max
	
	_health_bar.value = player_controller.health._health_current
	_protection_bar.value = player_controller.health._protection_current

func _on_touch_screen_button_pause_released() -> void:
	get_tree().paused = true
	pause_menu.set_visibility(true)
	set_visibility(false)
