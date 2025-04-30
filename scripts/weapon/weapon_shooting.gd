extends Sprite2D

@export var bullet: PackedScene
@export var fire_rate: float = 0.2
@export var damage: int = 10
@export var spread_degrees: float = 5.0
@export var muzzle_flash_time: float = 0.05
@export var bullets_per_shot: int = 1

@onready var muzzle: Marker2D = $"Marker2D (Muzzle)"
@onready var shoot_timer: Timer = $Timer
#@onready var muzzle_sprite: Sprite2D = $MuzzleFlash
#@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var can_shoot: bool = true
var bullet_speed: float = 600.0

func _ready():
	shoot_timer.wait_time = fire_rate
	#muzzle_sprite.visible = false

func shoot(direction: Vector2):
	if !can_shoot || !bullet:
		return
	
	# Создаем пулю
	for i in bullets_per_shot:
		var new_bullet = bullet.instantiate()
		get_parent().add_child(new_bullet)
		
		var bullet_dir = direction.rotated(deg_to_rad(spread_degrees * randf_range(-0.5, 0.5)))
		
		new_bullet.global_position = muzzle.global_position
		new_bullet.rotation = bullet_dir.angle()
		new_bullet.set_parameters(damage, bullet_speed, bullet_dir)

	# Эффекты выстрела
	#start_muzzle_flash()
	#audio_player.play()
	
	# Таймер перезарядки
	can_shoot = false
	shoot_timer.start()

func start_muzzle_flash():
	pass
	#muzzle_sprite.visible = true
	#await get_tree().create_timer(muzzle_flash_time).timeout
	#muzzle_sprite.visible = false

func _on_timer_timeout():
	can_shoot = true
