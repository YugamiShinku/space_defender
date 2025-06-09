class_name ActorAnimator extends AnimationTree

var movement_blend_position := Vector2.ZERO

func _process(_delta: float) -> void:
	if movement_blend_position.length() > 0:
		set("parameters/walk/blend_position", movement_blend_position)
		set("parameters/conditions/is_walking", true)
		set("parameters/conditions/is_idle", false)
	else:
		set("parameters/conditions/is_walking", false)
		set("parameters/conditions/is_idle", true)
