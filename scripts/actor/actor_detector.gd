class_name ActorDetector extends Area2D

var targets: Array[Node2D] = []

func _on_area_entered(area: Area2D) -> void:
	targets.append(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	targets.erase(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	targets.append(body)

func _on_body_exited(body: Node2D) -> void:
	targets.erase(body)

func get_nearest_target() -> Node2D:	
	var nearest_target: Node2D = null
	var min_distance: float = INF
	
	for target in targets:
		var distance = global_position.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_target = target
	return nearest_target
