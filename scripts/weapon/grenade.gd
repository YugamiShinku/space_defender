class_name Grenade extends Bullet

@onready var expolision_area := $"Area2D (Explosion)"

func _on_damage(_damaged: Node2D) -> void:
	for damaged in expolision_area.get_overlapping_areas():
		if damaged.has_method("take_damage"):
			damaged.take_damage(damage)
			
	for damaged in expolision_area.get_overlapping_bodies():
		if damaged.has_method("take_damage"):
			damaged.take_damage(damage)

	queue_free()

func _on_area_2d_collider_area_entered(area: Area2D) -> void:
	_on_damage(null)

func _on_area_2d_collider_body_entered(body: Node2D) -> void:
	_on_damage(null)
