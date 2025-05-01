class_name ActorHealth extends ActorEquipment

@export var health: float = 100.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func take_damage(damage):
	health -= damage
	print(health)
	if is_dead():
		self.queue_free()

func is_dead() -> bool:
	return health <= 0
