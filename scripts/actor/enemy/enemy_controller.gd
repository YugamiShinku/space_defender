class_name EnemyController extends Node2D

@export var movement: ActorMovement
@export var navigation: ActorNavigation
@export var equipment: ActorEquipment
@export var aim_detector: ActorDetector
@export var weapon_detector: ActorDetector
		
func _setup_movement_direction():
	if !navigation.is_navigation_finished(): movement.movement_direction = global_position.direction_to(navigation.get_next_path_position())
	else: movement.movement_direction = Vector2.ZERO
	
func _process(_delta: float) -> void:
	_setup_movement_direction()
	var current_weapon = equipment.get_current_weapon()
	if !current_weapon and weapon_detector.get_nearest_target():
		equipment.pickup_nearest_weapon()

	if aim_detector.get_nearest_target() && current_weapon:
		current_weapon.shoot()
