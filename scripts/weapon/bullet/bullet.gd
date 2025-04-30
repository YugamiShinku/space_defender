extends Sprite2D

@export var max_distance_range: Vector2 = Vector2(500, 800)

var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 0

var distance_traveled: float = 0.0
var max_distance: float = 0.0

func _ready() -> void:
	max_distance = randf_range(max_distance_range.x, max_distance_range.y)

func set_parameters(dmg: int, spd: float, dir: Vector2):
	self.damage = dmg
	self.speed = spd
	self.direction = dir


func _physics_process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	# Проверяем пройденную дистанцию
	if distance_traveled >= max_distance:
		queue_free()


func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
