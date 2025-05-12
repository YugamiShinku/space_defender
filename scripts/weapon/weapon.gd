class_name Weapon extends Node2D

@export var fire_rate: float = 0.2
@export var ammo: int = 10
@export var reload_time: float = 1.5
@onready var pickup_area: Area2D = $"Area2D (Pickup)"
@onready var muzzle: Marker2D = $"Marker2D (Muzzle)"
@export var bullets_per_shot_range: Vector2i =  Vector2(1, 1)
@export var spread_range: Vector2 = Vector2(-2.5, 2.5)
@export var bullet_scene: PackedScene
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var current_ammo: int = ammo
var _can_shoot: bool = true

var _shoot_timer: Timer

func _ready():
	_shoot_timer = Timer.new()
	_shoot_timer.wait_time = fire_rate
	_shoot_timer.timeout.connect(_on_reload)
	add_child(_shoot_timer)

func setup_pickable(enabled: bool):
	pickup_area.monitorable = enabled

func shoot():
	if !_can_shoot || current_ammo <= 0:
		return

	var direction = Vector2.RIGHT.rotated(global_rotation)

	current_ammo -= 1

	var bullets_per_shot = randf_range(bullets_per_shot_range.x, bullets_per_shot_range.y)
	for _i in bullets_per_shot:
		var bullet = bullet_scene.instantiate()	
		var bullet_direction = direction.rotated(deg_to_rad(randf_range(spread_range.x, spread_range.y)))
		bullet.initialize(bullet_direction)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position

	audio_player.play()
	
	if current_ammo <= 0:
		reload()
	
	_can_shoot = false
	_shoot_timer.start()

func reload():
	if current_ammo >= ammo:
		return
	
	_can_shoot = false

	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = ammo
	_can_shoot = true

func _on_reload():
	_can_shoot = true
