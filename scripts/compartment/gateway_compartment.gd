class_name GatewayCompartment extends Compartment

func generate(position: Vector2i) -> void:
	var rect = _get_rect(position)
	_paint_floor(rect)
	#_paint_walls(rect)
