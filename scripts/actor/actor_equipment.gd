class_name ActorEquipment extends ActorMovement

@export var max_weapons: int = 2
@export var weapon_rotation_speed: float = 7.5

@export var weapon_position: Marker2D

@export var weapon_detector: ActorDetector
@export var enemy_detector: ActorDetector

var weapons: Array[Weapon] = []
var current_weapon_i: int = -1

func _get_current_weapon() -> Weapon:
	if current_weapon_i == -1: return null
	return weapons[current_weapon_i]

func drop_current_weapon():
	if current_weapon_i == -1 || weapons.is_empty():
		return
	
	var weapon_to_drop = weapons.pop_at(current_weapon_i)
	weapon_to_drop.get_parent().remove_child(weapon_to_drop)
	get_parent().get_parent().add_child(weapon_to_drop)
	weapon_to_drop.global_position = weapon_position.global_position
	weapon_to_drop.visible = true
	weapon_to_drop.setup_pickable(true)
	
	if weapons.size() > 0:
		current_weapon_i = clamp(current_weapon_i, 0, weapons.size() - 1)
		switch_weapon(current_weapon_i)
	else:
		current_weapon_i = -1

func pickup_nearest_weapon():
	if weapon_detector.get_targets().is_empty(): return
	
	if weapons.size() >= max_weapons:
		drop_current_weapon()
	
	var weapon = weapon_detector.get_nearest_target()
	if !weapon: return
	weapon.get_parent().remove_child(weapon)
	weapon_position.add_child(weapon)
	weapon.global_position = weapon_position.global_position
	weapon.visible = false
	weapon.setup_pickable(false)
	
	weapons.append(weapon)
	switch_weapon(weapons.size() - 1)

func switch_to_next_weapon():
	if weapons.size() <= 1:
		return
	
	var new_index = current_weapon_i + 1
	if new_index >= weapons.size():
		new_index = 0
	
	switch_weapon(new_index)

func switch_weapon(index: int):
	if weapons.is_empty() || index < 0 || index >= weapons.size():
		current_weapon_i = -1
		return
	
	var previous_rotation: float = weapons[current_weapon_i].global_rotation if weapons[current_weapon_i] else 0.0
	var previous_scale_y: float = weapons[current_weapon_i].scale.y if weapons[current_weapon_i] else 1.0
	
	if current_weapon_i != -1 && current_weapon_i < weapons.size():
		weapons[current_weapon_i].visible = false
	
	current_weapon_i = index
	weapons[current_weapon_i].visible = true
	
	weapons[current_weapon_i].global_rotation = previous_rotation
	weapons[current_weapon_i].scale.y = previous_scale_y

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if current_weapon_i != -1:
		update_weapon_rotation(delta)

func update_weapon_rotation(delta: float):
	var target: Vector2 
	
	var enemy_target = enemy_detector.get_nearest_target()
	if enemy_target: target = enemy_target.global_position - self.global_position
	else: target = movement_direction

	if target.length() > 0.1:
		if target.x < 0: weapons[current_weapon_i].scale.y = -1
		elif target.x > 0: weapons[current_weapon_i].scale.y = 1
		
		weapons[current_weapon_i].global_rotation = lerp_angle(
			weapons[current_weapon_i].global_rotation,
			target.angle(),
			weapon_rotation_speed * delta
		)
