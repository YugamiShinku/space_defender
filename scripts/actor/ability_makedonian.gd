class_name ActorAbility extends Node2D

@export var duration := 5.0 
@export var cooldown := 10.0
@export var equipment: ActorEquipment

@onready var duration_timer := Timer.new()
@onready var cooldown_timer := Timer.new()

var is_active := false
var can_use := true
var _current := 100.0

func _ready() -> void:
	duration_timer.wait_time = duration / 100.0
	duration_timer.timeout.connect(_on_ability)
	add_child(duration_timer)
	
	cooldown_timer.autostart = true
	cooldown_timer.wait_time = cooldown / 100.0
	cooldown_timer.timeout.connect(_on_cooldown)
	add_child(cooldown_timer)

func activate() -> void:
	if is_active or !can_use or equipment._weapons.size() < 2: return
	
	is_active = true
	can_use = false
	
	equipment._current_weapons = [equipment._weapons.size() - 2, equipment._weapons.size() - 1]
	equipment._update_weapon_visibility()
	
	duration_timer.start()
	
func _on_ability() -> void:
	if _current <= 0.0:
		if is_active: 
			equipment._current_weapons = [equipment._weapons.size() - 1]
			equipment._update_weapon_visibility()
			cooldown_timer.start()
		is_active = false
		duration_timer.stop()
		return
	
	_current -= 1.0
	
func _on_cooldown() -> void:
	if _current >= 100.0:
		can_use = true
		cooldown_timer.stop()
		return

	_current += 1.0

func is_dual_fire_active() -> bool:
	return is_active
