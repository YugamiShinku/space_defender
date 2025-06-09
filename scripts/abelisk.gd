class_name Abelisk extends Node2D

@onready var area: Area2D = $"Area2D"
@export var director: Director

func _on_area_2d_area_entered(area: Area2D) -> void:
	area.monitoring = false
	#director._tilemap_generator.destroy_previous_room()
