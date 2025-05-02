class_name ActorHealth extends ActorAimer

@export var health: float = 100.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func take_damage(damage):
	#print("take damage: ", self.name)
	health -= damage
	if is_dead():
		self.queue_free()

func is_dead() -> bool:
	return health <= 0
