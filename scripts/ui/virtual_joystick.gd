@tool
class_name VirtualJoystick extends Node2D

signal analogic_change(move: Vector2)
signal analogic_just_pressed
signal analogic_released

@export var border: Texture2D:
	set(value):
		border = value
		_draw()
@export var stick: Texture2D:
	set(value):
		stick = value
		_draw()
@export var stick_pressed: Texture2D
@export var return_acceleration := 16
@export var threshold := 8
@export var radius := Vector2(24, 24)
@export var boundary := 16

var _joystick := Sprite2D.new()
var _touch := TouchScreenButton.new()

var _ongoing_drag := -1
var _is_pressed := false
var default_global_position = global_position

func _draw() -> void:	
	if get_child_count() == 0:
		add_child(_joystick)
		
	if _joystick.get_child_count() == 0:
		_joystick.add_child(_touch)	
		
	_joystick.texture = border
	_touch.texture_normal = stick

func _ready() -> void:	
	_touch.position = -radius
	_touch.released.connect(analogic_released.emit)

	if ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"):
		printerr("The Project Setting 'emulate_mouse_from_touch' should be set to False")
	if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		printerr("The Project Setting 'emulate_touch_from_mouse' should be set to True")

func _process(delta: float) -> void:
	if _ongoing_drag == -1:
		var pos_difference = (Vector2.ZERO - radius) - _touch.position
		_touch.position += pos_difference * return_acceleration * delta * 2	

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		var event_dist_from_center = (event.position - global_position).length()

		if event_dist_from_center <= boundary * global_scale.x or event.get_index() == _ongoing_drag:
			if !_is_pressed:
				_is_pressed = true
				emit_signal("analogic_just_pressed")
				
				_touch.texture_normal = stick_pressed
			
			_touch.global_position = event.position - radius * global_scale
			
			if _get_button_position().length() > boundary:
				_touch.position = _get_button_position().normalized() * boundary - radius

			_ongoing_drag = event.get_index()
			analogic_change.emit(_get_value())		

	if event is InputEventScreenTouch and not event.is_pressed() and event.get_index() == _ongoing_drag:
		_ongoing_drag = -1
		analogic_change.emit(Vector2.ZERO)
		global_position = default_global_position
		_is_pressed = false
		_touch.texture_normal = stick
		
func _get_button_position() -> Vector2:
	return _touch.position + radius
	
func _get_value() -> Vector2:
	if _get_button_position().length() > threshold:
		return _get_button_position().normalized()
	return Vector2.ZERO

func _on_analogic_change(move: Vector2) -> void:
	Input.action_press("move_left", -move.x)
	Input.action_press("move_right", move.x)
	
	Input.action_press("move_up", -move.y)
	Input.action_press("move_down", move.y)
