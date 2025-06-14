extends Node2D

@export var heal := 20

func _heal(healed: Node2D) -> void:
	if healed.is_in_group("Player"):
		healed.heal(heal)
		queue_free.call_deferred()

func _on_area_2d_collider_area_entered(area: Area2D) -> void:
	_heal(area.get_parent())

func _on_area_2d_collider_body_entered(body: Node2D) -> void:
	_heal(body)
