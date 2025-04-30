extends Sprite2D

@export var bullet: PackedScene
@export var fire_rate: float = 0.2
@export var damage: int = 10
@export var spread_degrees_range: Vector2 = Vector2(-2.5, 2.5)
@export var muzzle_flash_time: float = 0.1
@export var bullets_per_shot_range: Vector2i =  Vector2(1, 1)
@export var max_distance_range: Vector2 = Vector2(500, 800)
@export var bullet_speed_range: Vector2 = Vector2(500, 700)

@onready var muzzle: Marker2D = $"Marker2D (Muzzle)"
@onready var shoot_timer: Timer = $Timer
@onready var muzzle_sprite: Sprite2D = $"Sprite2D (Muzzle)"
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var can_shoot: bool = true

func _ready():
	shoot_timer.wait_time = fire_rate
	muzzle_sprite.visible = false

func shoot(direction: Vector2):
	if !can_shoot || !bullet:
		return

	var bullets_per_shot = randf_range(bullets_per_shot_range.x, bullets_per_shot_range.y)
	for i in bullets_per_shot:
		var new_bullet = bullet.instantiate()
		get_parent().add_child(new_bullet)
		
		var bullet_dir = direction.rotated(deg_to_rad(randf_range(spread_degrees_range.x, spread_degrees_range.y)))
		
		new_bullet.global_position = muzzle.global_position
		new_bullet.rotation = bullet_dir.angle()
		new_bullet.set_parameters(damage, bullet_dir, bullet_speed_range, max_distance_range)

	# Эффекты выстрела
	start_muzzle_flash()
	audio_player.play()
	
	# Таймер перезарядки
	can_shoot = false
	shoot_timer.start()

func start_muzzle_flash():
	muzzle_sprite.visible = true
	await get_tree().create_timer(muzzle_flash_time).timeout
	muzzle_sprite.visible = false

func _on_timer_timeout():
	can_shoot = true
