extends Sprite2D

var speed: float
var direction: Vector2
var damage: int


func set_parameters(damage: int, bullet_speed: float, dir: Vector2):
	self.damage = damage
	self.speed = bullet_speed
	self.direction = dir

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
