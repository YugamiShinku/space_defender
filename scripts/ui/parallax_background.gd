extends ParallaxBackground

@export var scrolling_speed := 40

func _process(delta: float):
	scroll_offset.x -= scrolling_speed * delta
