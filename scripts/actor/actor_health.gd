class_name ActorHealth extends Area2D

signal after_take_damage(damage: float)

@export_range(0.0, 1000.0, 1.0) var _health_max := 100.0
@export var protection_restoring := true
@export_range(0.0, 10.0, 0.01) var protection_restoring_rate := 0.25
@export_range(0.0, 10.0, 0.1) var protection_restoring_count := 1.0
@export_range(0.0, 1000.0, 1.0) var _protection_max := 100.0

@onready var _health_current := _health_max
@onready var _protection_current := _protection_max

@onready var _protection_restoring_timer := Timer.new()

func _ready() -> void:
	_protection_restoring_timer.wait_time = protection_restoring_rate
	_protection_restoring_timer.autostart = protection_restoring
	_protection_restoring_timer.timeout.connect(_on_restore)
	add_child(_protection_restoring_timer)

func take_damage(damage: float) -> void:
	var health_damage = 0.0
	var protection_damage = 0.0
	
	# Рассчитываем урон по защите
	var calc_damage := damage
	if _protection_current > 0:
		protection_damage = min(calc_damage, _protection_current)
		_protection_current -= protection_damage
		calc_damage -= protection_damage
	
	# Оставшийся урон применяем к здоровью
	if calc_damage > 0:
		health_damage = min(calc_damage, _health_current)
		_health_current -= health_damage
	
	# Отправляем сигнал с детализацией урона
	after_take_damage.emit(damage)

func is_dead() -> bool:
	return _health_current <= 0

func _on_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage)

func _on_restore() -> void:
	if _protection_current >= _protection_max and protection_restoring: return
	_protection_current = min(_protection_current + protection_restoring_count, _protection_max)
