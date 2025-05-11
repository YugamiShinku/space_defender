class_name ActorHealth extends Area2D

@export var health: float = 100.0

func take_damage(damage):
	health -= damage
	if is_dead():
		get_parent().queue_free()

func is_dead() -> bool:
	return health <= 0

func _on_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage)
