extends Node

@export var weapon_position: Marker2D
@export var pickup_area: Area2D
@export var rotation_speed: float = 7.5

var current_weapon: Node2D = null
var near_weapons: Array[Node2D] = []

func _ready():	
	pickup_area.area_entered.connect(_on_weapon_entered)
	pickup_area.area_exited.connect(_on_weapon_exited)

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

func _physics_process(delta):
	if current_weapon:
		update_weapon_rotation(delta)
		
	if Input.is_action_pressed("shoot") && current_weapon:
		if current_weapon.has_method("shoot"):
			var shoot_direction = Vector2.RIGHT.rotated(current_weapon.global_rotation)
			current_weapon.shoot(shoot_direction)


func update_weapon_rotation(delta: float):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction.length() > 0.1:
		var target_angle = input_direction.angle()
		
		if input_direction.x < 0:
			current_weapon.scale.y = -1
		elif input_direction.x > 0:
			current_weapon.scale.y = 1
		
		current_weapon.global_rotation = lerp_angle(
			current_weapon.global_rotation,
			target_angle,
			rotation_speed * delta
		)
