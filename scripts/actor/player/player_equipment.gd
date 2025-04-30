extends Node

@export var max_weapons: int = 2

@export var weapon_rotation_speed: float = 7.5

@export var weapon_position: Marker2D
@export var pickup_area: Area2D
@export var detection_area: Area2D

#@onready var weapon_position: Marker2D = $"Market2D (Weapon)"
#@onready var pickup_area: Area2D = $"Area2D (Pickup)"
#@onready var detection_area: Area2D = $"Area2D (Detector)"

var weapons: Array[Node2D] = []
var current_weapon_i: int = -1

var current_weapon: Node2D = null
var near_weapons: Array[Node2D] = []

var current_enemy: Node2D = null
var near_enemies: Array[Node2D] = []

func _ready():	
	pickup_area.area_entered.connect(_on_weapon_entered)
	pickup_area.area_exited.connect(_on_weapon_exited)
	
	detection_area.area_entered.connect(_on_enemy_detected)
	detection_area.area_exited.connect(_on_enemy_lost)

func _input(event):
	if event.is_action_pressed("equip") and near_weapons.size() > 0:
		pickup_weapon(near_weapons[0])
		
	if event.is_action_pressed("drop"):
		drop_current_weapon()
		
	if event.is_action_pressed("switch"):
		switch_to_next_weapon()

func drop_current_weapon():
	if current_weapon_i == -1 || weapons.is_empty():
		return
	
	var weapon_to_drop = weapons.pop_at(current_weapon_i)
	weapon_to_drop.get_parent().remove_child(weapon_to_drop)
	get_parent().get_parent().add_child(weapon_to_drop)
	weapon_to_drop.global_position = weapon_position.global_position
	weapon_to_drop.visible = true
	weapon_to_drop.set_collision_layer_value(1, true)
	
	# Переключаемся на следующее оружие
	if weapons.size() > 0:
		current_weapon_i = clamp(current_weapon_i, 0, weapons.size() - 1)
		switch_weapon(current_weapon_i)
	else:
		current_weapon_i = -1
		current_weapon = null

func pickup_weapon(weapon: Node2D):
	if weapons.size() >= max_weapons:
		drop_current_weapon()
	
	weapon.get_parent().remove_child(weapon)
	weapon_position.add_child(weapon)
	weapon.global_position = weapon_position.global_position
	weapon.visible = false
	weapon.set_collision_layer_value(1, false)
	
	weapons.append(weapon)
	switch_weapon(weapons.size() - 1)
	
	near_weapons.erase(weapon)

func switch_to_next_weapon():
	if weapons.size() <= 1:
		return  # Нечего переключать
	
	var new_index = current_weapon_i + 1
	if new_index >= weapons.size():
		new_index = 0  # Циклический переход в начало
	
	switch_weapon(new_index)

func switch_weapon(index: int):
	if weapons.is_empty() || index < 0 || index >= weapons.size():
		current_weapon_i = -1
		current_weapon = null
		return
	
	# Сохраняем параметры текущего оружия
	var previous_rotation: float = current_weapon.global_rotation if current_weapon else 0.0
	var previous_scale_y: float = current_weapon.scale.y if current_weapon else 1.0
	
	# Скрываем предыдущее оружие
	if current_weapon_i != -1 && current_weapon_i < weapons.size():
		weapons[current_weapon_i].visible = false
	
	# Показываем новое
	current_weapon_i = index
	weapons[current_weapon_i].visible = true
	current_weapon = weapons[current_weapon_i]
	
	# Применяем сохраненные параметры
	current_weapon.global_rotation = previous_rotation
	current_weapon.scale.y = previous_scale_y

func _on_weapon_entered(body: Node2D):
	near_weapons.append(body.get_parent())

func _on_weapon_exited(body: Node2D):
	near_weapons.erase(body.get_parent())

func _on_enemy_detected(body: Node2D):
	near_enemies.append(body.get_parent())

func _on_enemy_lost(body: Node2D):
	near_enemies.erase(body.get_parent())

func _physics_process(delta):
	if current_weapon:
		update_weapon_rotation(delta)
		
	if Input.is_action_pressed("shoot") && current_weapon:
		if current_weapon.has_method("shoot"):
			var shoot_direction = Vector2.RIGHT.rotated(current_weapon.global_rotation)
			current_weapon.shoot(shoot_direction)

func get_enemy_target() -> Node2D:
	if near_enemies.is_empty():
		return null
	
	var closest_enemy: Node2D = null
	var min_distance: float = INF
	
	for enemy in near_enemies:
		var distance = self.global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func update_weapon_rotation(delta: float):
	var target: Vector2 
	
	var enemy_target = get_enemy_target()
	if enemy_target: target = enemy_target.global_position - self.global_position
	else: target = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if target.length() > 0.1:
		if target.x < 0: current_weapon.scale.y = -1
		elif target.x > 0: current_weapon.scale.y = 1
		
		current_weapon.global_rotation = lerp_angle(
			current_weapon.global_rotation,
			target.angle(),
			weapon_rotation_speed * delta
		)
