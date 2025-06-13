class_name EnvironmentAudio extends AudioStreamPlayer2D

var interpolation_speed: float = 0.01

func _process(delta: float) -> void:
	var target_pitch = lerp(1.25, 1.75, get_tree().get_nodes_in_group("Enemy").size() / 4)
	pitch_scale = lerp(pitch_scale, target_pitch, interpolation_speed * delta)
