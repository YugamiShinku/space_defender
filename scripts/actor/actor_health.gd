class_name ActorHealth extends ActorEquipment

@export_category("Health")
@export var health: float = 100.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func take_damage(damage):
	health -= damage

func is_dead() -> bool:
	return health <= 0
