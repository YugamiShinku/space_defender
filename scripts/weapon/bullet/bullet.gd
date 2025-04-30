extends Sprite2D

var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 0

var distance_traveled: float = 0.0
var max_distance: float = 0.0

func set_parameters(dmg: int, dir: Vector2, sr: Vector2, mdr: Vector2):
	self.damage = dmg
	self.direction = dir
	self.speed = randf_range(sr.x, sr.y)
	self.max_distance = randf_range(mdr.x, mdr.y)


func _physics_process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_distance:
		queue_free()


func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
