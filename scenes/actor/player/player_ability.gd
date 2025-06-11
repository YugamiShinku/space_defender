class_name PlayerAbility extends Node

@export var duration: float = 5.0  
@export var cooldown: float = 10.0  
@export var input_action: String = "ability"  
@export var weapon_offset: Vector2 = Vector2(10, -10)

@onready var timer: Timer = $Timer
@onready var cooldown_timer: Timer = $CooldownTimer

var equipment: ActorEquipment
var is_active: bool = false
var can_use: bool = true
var original_positions: Array[Vector2] = []

func _ready() -> void:
	equipment = get_parent().get_node("ActorEquipment")
	timer.one_shot = true
	timer.timeout.connect(_on_ability_end)
	
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(input_action) and can_use and not is_active:
		activate()

func activate() -> void:
	if equipment._weapons.size() < 2:
		return
	
	is_active = true
	can_use = false
	
	original_positions = []
	for weapon in equipment._weapons:
		original_positions.append(weapon.position)
		
	equipment._weapons[0].position = original_positions[0]
	equipment._weapons[1].position = original_positions[1] + weapon_offset
	
	for weapon in equipment._weapons:
		weapon.visible = true
	
	timer.start(duration)
	cooldown_timer.start(cooldown + duration)
	
func _on_ability_end() -> void:
	is_active = false
	for i in range(equipment._weapons.size()):
		if i < original_positions.size():
			equipment._weapons[i].position = original_positions[i]
	equipment._update_weapon_visibility()
	
func _on_cooldown_end() -> void:
	can_use = true

func is_dual_fire_active() -> bool:
	return is_active
