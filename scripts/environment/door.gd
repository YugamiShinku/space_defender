class_name Door extends Node2D

@export var detector: ActorDetector
@export var animation_player: AnimationPlayer
@export var delay: float

var _opened: bool = false
var _delay_timer: Timer

func _ready():
	_delay_timer = Timer.new()
	_delay_timer.wait_time = delay
	_delay_timer.timeout.connect(_close)
	add_child(_delay_timer)

func _process(_delta: float) -> void:
	if !detector.get_targets().is_empty():
		_open()
	else:
		if _opened && _delay_timer.is_stopped():
			_delay_timer.start()

func _open() -> void:
	if !detector.get_targets().is_empty():
		if !_opened:
			animation_player.play("open")
			_opened = true
		if !_delay_timer.is_stopped():
			_delay_timer.stop()	

func _close() -> void:
	if detector.get_targets().is_empty() && _opened:
		animation_player.play_backwards("open")
		_opened = false
