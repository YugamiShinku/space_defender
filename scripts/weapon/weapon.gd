class_name Weapon extends Node2D

@export_range(0.0, 10.0, 0.1) var fire_rate := 0.2
@export_range(0, 100, 1) var ammo := 10
@export_range(0.0, 10.0, 0.1) var reload_time := 1.5
@export_range(0, 180, 1) var spread := -2.5
@export var bullets_per_shot_range := Vector2i(1, 1)
@export var bullet_scene: PackedScene

@export var scene_path: String

@onready var muzzle := $"Marker2D (Muzzle)"
@onready var pickup_area := $"Area2D (Pickup)"

@onready var _shoot_timer := Timer.new()

var _current_ammo := ammo
var _can_shoot := true

func _ready():
	_shoot_timer.wait_time = fire_rate
	_shoot_timer.timeout.connect(_on_reload)
	add_child(_shoot_timer)

func set_pickable(enabled: bool):
	pickup_area.monitorable = enabled

func shoot() -> int:
	if !_can_shoot || _current_ammo <= 0:
		return 0

	var direction = Vector2.RIGHT.rotated(global_rotation)

	_current_ammo -= 1

	var bullets_count = randi_range(bullets_per_shot_range.x, bullets_per_shot_range.y)
	for _i in bullets_count:
		var bullet: Bullet = bullet_scene.instantiate()	
		var bullet_direction = direction.rotated(deg_to_rad(randf_range(-spread, spread)))
		bullet.initialize(bullet_direction)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position
	
	if _current_ammo <= 0:
		reload()
	
	_can_shoot = false
	_shoot_timer.start()
	
	return bullets_count

func reload():
	if _current_ammo >= ammo:
		return
	
	_can_shoot = false

	await get_tree().create_timer(reload_time).timeout
	
	_current_ammo = ammo
	_can_shoot = true

func _on_reload():
	_can_shoot = true
