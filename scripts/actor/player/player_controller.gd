class_name PlayerController extends Node2D

@export var movement: ActorMovement
@export var equipment: ActorEquipment

func _setup_movement_direction():
	movement.movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		var current_weapon = equipment.get_current_weapon()
		if current_weapon: current_weapon.reload()
	
	if event.is_action_pressed("equip"):
		equipment.pickup_nearest_weapon()
		
	if event.is_action_pressed("drop"):
		equipment.drop_current_weapon()
		
	if event.is_action_pressed("switch"):
		equipment.switch_to_next_weapon()

func _process(_delta: float) -> void:
	_setup_movement_direction()
	var current_weapon = equipment.get_current_weapon()
	if Input.is_action_pressed("shoot") && current_weapon:
		current_weapon.shoot()
