class_name PlayerController extends ActorController

@export var enemy_spawner: TileampSpawner
@export var weapon_spawner: TileampSpawner

func _setup_movement_direction():
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("equip"):
		pickup_nearest_weapon()
		
	if event.is_action_pressed("drop"):
		drop_current_weapon()
		enemy_spawner.spawn()
		
	if event.is_action_pressed("switch"):
		switch_to_next_weapon()
		weapon_spawner.spawn()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	var current_weapon = get_current_weapon()
	if Input.is_action_pressed("shoot") && current_weapon:
		current_weapon.shoot(Vector2.RIGHT.rotated(current_weapon.global_rotation))
