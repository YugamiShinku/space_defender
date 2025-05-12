class_name ActorHealth extends Node2D

@export_range(0.0, 1000.0, 1.0) var max_health: float = 100.0
var current_health: float = max_health

func take_damage(damage: float):
	current_health -= damage

func is_dead() -> bool:
	return current_health <= 0
