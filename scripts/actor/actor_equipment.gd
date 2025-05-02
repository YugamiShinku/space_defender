class_name ActorEquipment extends ActorMovement

@export var collision_hitbox: int

@export var max_weapons: int = 2
@export var weapon_position: Marker2D
@export var weapon_detector: ActorDetector

@export var weapons: Array[Weapon] = []
@export var current_weapon_i: int = -1

func get_current_weapon() -> Weapon:
	if current_weapon_i == -1: return null
	return weapons[current_weapon_i]

func _position_weapon(weapon: Weapon, pickable: bool) -> void:
	weapon.global_position = weapon_position.global_position
	weapon.setup_pickable(pickable)

func drop_current_weapon() -> void:
	if current_weapon_i == -1: return
	
	var weapon = weapons.pop_at(current_weapon_i)
	weapon.get_parent().remove_child(weapon)
	get_tree().current_scene.add_child(weapon)
	
	_position_weapon(weapon, true)

	if weapons.is_empty(): current_weapon_i = -1
	else: current_weapon_i = weapons.size() - 1
	
	_update_weapon_visibility()

func pickup_nearest_weapon() -> void:
	var weapon = weapon_detector.get_nearest_target()
	if !weapon: return
	
	if weapons.size() >= max_weapons: drop_current_weapon()
	
	weapon.get_parent().remove_child(weapon)
	weapon_position.add_child(weapon)
	
	_position_weapon(weapon, false)

	weapons.append(weapon)
	
	current_weapon_i = weapons.size() - 1
	_update_weapon_visibility()

func switch_to_next_weapon() -> void:
	if current_weapon_i == -1: return
	
	current_weapon_i = (current_weapon_i + 1) % weapons.size()
	_update_weapon_visibility()

func _update_weapon_visibility() -> void:
	for i in range(weapons.size()):
		weapons[i].visible = (i == current_weapon_i)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
