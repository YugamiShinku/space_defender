class_name ActorTargetNavigation extends ActorNavigation

@export var jitter_radius_range := Vector2(75.0, 125.0)
@export var jitter_update_interval_range := Vector2(0.5, 0.75)
@export var detector: ActorDetector

@onready var _jitter_timer := Timer.new()

var _current_jitter := Vector2.ZERO

func _ready() -> void:
	_jitter_timer.wait_time = randf_range(jitter_update_interval_range.x, jitter_update_interval_range.y)
	_jitter_timer.autostart = true
	_jitter_timer.timeout.connect(_update_jitter)
	add_child(_jitter_timer)

func _update_jitter() -> void:
	if !is_navigation_finished(): return
	
	_jitter_timer.wait_time = randf_range(jitter_update_interval_range.x, jitter_update_interval_range.y)
	var random_angle := randf_range(0, TAU)
	var jitter_radius := randf_range(jitter_radius_range.x, jitter_radius_range.y)
	_current_jitter = Vector2(cos(random_angle), sin(random_angle)) * jitter_radius

func _get_target_position() -> Vector2:
	var nearest_target = detector.get_nearest_target()
	if nearest_target:
		return nearest_target.global_position + _current_jitter
	return get_final_position()
		
func _process(delta: float) -> void:
	super._process(delta)
