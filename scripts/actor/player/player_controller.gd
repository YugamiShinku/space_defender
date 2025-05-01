class_name PlayerController extends ActorController

func _setup_movement_direction():
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("equip"):
		pickup_nearest_weapon()
		
	if event.is_action_pressed("drop"):
		drop_current_weapon()
		
	if event.is_action_pressed("switch"):
		switch_to_next_weapon()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if Input.is_action_pressed("shoot") && _get_current_weapon():
		if weapons[current_weapon_i].has_method("shoot"):
			var shoot_direction = Vector2.RIGHT.rotated(weapons[current_weapon_i].global_rotation)
			weapons[current_weapon_i].shoot(shoot_direction)
