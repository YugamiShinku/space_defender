extends Sprite2D

@export var bullet: PackedScene
@export var fire_rate: float = 0.2
@export var damage: int = 10
@export var spread_degrees: float = 5.0
@export var muzzle_flash_time: float = 0.05

@onready var muzzle: Marker2D = $"Marker2D (Muzzle)"
@onready var shoot_timer: Timer = $Timer
#@onready var muzzle_sprite: Sprite2D = $MuzzleFlash
#@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var can_shoot: bool = true
var bullet_speed: float = 600.0

func _ready():
	shoot_timer.wait_time = fire_rate
	#muzzle_sprite.visible = false

func shoot():
	if !can_shoot || !bullet:
		return
	
	# Создаем пулю
	var new_bullet = bullet.instantiate()
	get_tree().root.add_child(new_bullet)
	
	# Рассчитываем направление с разбросом
	var spread = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var direction = Vector2.RIGHT.rotated(global_rotation + spread)
	
	# Настраиваем пулю
	new_bullet.global_position = muzzle.global_position
	new_bullet.rotation = direction.angle()
	new_bullet.set_parameters(damage, bullet_speed, direction)
	
	# Эффекты выстрела
	start_muzzle_flash()
	#audio_player.play()
	
	# Таймер перезарядки
	can_shoot = false
	shoot_timer.start()

func start_muzzle_flash():
	#muzzle_sprite.visible = true
	await get_tree().create_timer(muzzle_flash_time).timeout
	#muzzle_sprite.visible = false

func _on_timer_timeout():
	can_shoot = true
