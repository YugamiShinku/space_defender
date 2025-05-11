class_name Weapon extends Sprite2D

@export_category("Weapon")
@export var fire_rate: float = 0.2
@export var magazines: int = 3
@export var max_ammo_in_magazine: int = 10
@export var reload_time: float = 1.5
@onready var shoot_timer: Timer = $Timer
@onready var pickup_area: Area2D = $"Area2D (Pickup)"
@onready var muzzle: Marker2D = $"Marker2D (Muzzle)"
var current_ammo: int = max_ammo_in_magazine
var _can_shoot: bool = true

@export_category("Bullet")
@export var bullet_scene: PackedScene
@export var bullet_damage: int = 10
@export var bullet_spread_degrees_range: Vector2 = Vector2(-2.5, 2.5)
@export var bullets_per_shot_range: Vector2i =  Vector2(1, 1)
@export var bullet_max_distance_range: Vector2 = Vector2(500, 800)
@export var bullet_speed_range: Vector2 = Vector2(500, 700)

@export_category("Visual Effects")
@export var muzzle_flash_time: float = 0.1
@onready var muzzle_sprite: Sprite2D = $"Sprite2D (Muzzle)"

@export_category("Audio Effects")
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	shoot_timer.wait_time = fire_rate

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
		var bullet_direction = direction.rotated(deg_to_rad(randf_range(bullet_spread_degrees_range.x, bullet_spread_degrees_range.y)))
		var bullet_speed = randf_range(bullet_speed_range.x, bullet_speed_range.y)
		var bullet_max_distance = randf_range(bullet_max_distance_range.x, bullet_max_distance_range.y)
	
		bullet.initialize(bullet_damage, bullet_direction, bullet_speed, bullet_max_distance)
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = muzzle.global_position

	start_muzzle_flash()
	audio_player.play()
	
	if current_ammo <= 0:
		reload()
	
	_can_shoot = false
	shoot_timer.start()

func reload():
	if current_ammo >= max_ammo_in_magazine:
		return
	
	_can_shoot = false

	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = max_ammo_in_magazine
	_can_shoot = true

func start_muzzle_flash():
	muzzle_sprite.visible = true
	await get_tree().create_timer(muzzle_flash_time).timeout
	muzzle_sprite.visible = false

func _on_timer_timeout():
	_can_shoot = true

	if current_ammo <= 0:
		reload()
