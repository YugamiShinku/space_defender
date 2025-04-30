extends Node

@export var weapon_rotation_speed: float = 7.5

@export var weapon_position: Marker2D
@export var pickup_area: Area2D
@export var detection_area: Area2D

#@onready var weapon_position: Marker2D = $"Market2D (Weapon)"
#@onready var pickup_area: Area2D = $"Area2D (Pickup)"
#@onready var detection_area: Area2D = $"Area2D (Detector)"

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

func drop_current_weapon():
	if current_weapon:
		current_weapon.get_parent().remove_child(current_weapon)
		get_parent().get_parent().add_child(current_weapon)
		current_weapon.global_position = weapon_position.global_position	
		current_weapon = null

func pickup_weapon(weapon: Node2D):
	drop_current_weapon()
	
	weapon.get_parent().remove_child(weapon)
	weapon_position.add_child(weapon)
	weapon.global_position = weapon_position.global_position
	current_weapon = weapon
	near_weapons.erase(weapon)

func _on_weapon_entered(body: Node2D):
	near_weapons.append(body.get_parent())

func _on_weapon_exited(body: Node2D):
	near_weapons.erase(body.get_parent())

func _on_enemy_detected(body: Node2D):
	print("enemy detected")
	near_enemies.append(body.get_parent())

func _on_enemy_lost(body: Node2D):
	print("enemy lost")
	near_enemies.erase(body.get_parent())

func _physics_process(delta):
	if current_weapon:
		update_weapon_rotation(delta)
		
	if Input.is_action_pressed("shoot") && current_weapon:
		if current_weapon.has_method("shoot"):
			var shoot_direction = Vector2.RIGHT.rotated(current_weapon.global_rotation)
			current_weapon.shoot(shoot_direction)

func get_target() -> Node2D:
	if near_enemies.is_empty():
		return null
	
	# Ищем ближайшего противника
	var closest_enemy: Node2D = null
	var min_distance: float = INF
	
	for enemy in near_enemies:
		var distance = self.global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func update_weapon_rotation(delta: float):
	var target_direction: Vector2 
	var target_angle: float
	
	var target = get_target()
	if target:
		target_direction = target.global_position - self.global_position
		target_angle = target_direction.angle()
		update_weapon_flip(target_direction)
		
		print("update rotation with enemy")
		current_weapon.global_rotation = lerp_angle(
			current_weapon.global_rotation,
			target_angle,
			weapon_rotation_speed * delta
		)
	else:
		target_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if target_direction.length() > 0.1:
			target_angle = target_direction.angle()
			update_weapon_flip(target_direction)
		
			print("update rotation without enemy")
			current_weapon.global_rotation = lerp_angle(
				current_weapon.global_rotation,
				target_angle,
				weapon_rotation_speed * delta
			)

func update_weapon_flip(target_direction: Vector2):
	if target_direction.x < 0:
		current_weapon.scale.y = -1
	elif target_direction.x > 0:
		current_weapon.scale.y = 1
