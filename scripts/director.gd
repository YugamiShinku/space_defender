class_name Director extends Node2D

@onready var _tilemap_generator: TileMapGenerator = $"Tilemap Generator"
@onready var _tilemap_spawner: TilemapSpawner = $"Tilemap Spawner"
@onready var _main_menu: MainMenu = $"MainMenu"
@onready var _game_menu: GameMenu = $"GameMenu"
@onready var _pause_menu: PauseMenu = $"PauseMenu"
@onready var _settings_menu: SettingsMenu = $"SettingsMenu"
@onready var _quit_menu: QuitMenu = $"QuitMenu"
@onready var _environment_audio: AudioStreamPlayer2D = $"AudioStreamPlayer2D"

@onready var _player_scene: PackedScene = preload("res://scenes/actor/player/player.tscn")

var _player_controller: PlayerController

var _after_next_room_timer := Timer.new()
var _wave_delay_timer := Timer.new()
var _enemy_spawn_timer := Timer.new()

var _can_spawn := true
var _is_wave_active := false

var _triggers: Array[Area2D] = []

var _spawned_count_range := Vector2i(6,9)
var _spawned_count_in_wave_range := Vector2i(1,3)
var _spawned_count := 0
var _wave_count_range := Vector2i(1, 3)
var _wave_count := 0
var _current_wave := -1
var _enemies_to_spawn_in_current_wave := 0

func _ready() -> void:
	var load_data := SaveLoad.load_data()
	
	_player_controller = _player_scene.instantiate()
	get_tree().current_scene.add_child(_player_controller)
	
	if load_data:
		_player_controller.health._health_current = load_data._player_health
		for weapon_scene_path in load_data._weapons_scene_paths:
			print("loaded: ", weapon_scene_path)
			var weapon_scene: Weapon = load(weapon_scene_path).instantiate()
			get_tree().current_scene.add_child(weapon_scene)
			_player_controller.equipment.pickup_weapon(weapon_scene)

	if !load_data or load_data._weapons_scene_paths.is_empty():
		var weapon_scene: Weapon = preload("res://scenes/weapon/pioner.tscn").instantiate()
		get_tree().current_scene.add_child(weapon_scene)
		_player_controller.equipment.pickup_weapon(weapon_scene)
	
	_game_menu.player_controller = _player_controller
	
	get_tree().paused = true
	_environment_audio.play()
	_main_menu.set_visibility(true)
	_game_menu.set_visibility(false)
	_pause_menu.set_visibility(false)
	_settings_menu.set_visibility(false)
	_quit_menu.set_visibility(false)
	
	# Настройка таймеров
	_after_next_room_timer.wait_time = 1.0
	_after_next_room_timer.one_shot = true
	_after_next_room_timer.timeout.connect(_after_next_room)
	add_child(_after_next_room_timer)
	
	_wave_delay_timer.wait_time = 1.0
	_wave_delay_timer.one_shot = true
	_wave_delay_timer.timeout.connect(_start_next_wave)
	add_child(_wave_delay_timer)
	
	_enemy_spawn_timer.one_shot = true
	_enemy_spawn_timer.timeout.connect(_spawn_enemy_in_wave)
	add_child(_enemy_spawn_timer)
	
	# Инициализация игры
	get_tree().paused = true
	_environment_audio.play()
	_game_menu.visible = false
	_pause_menu.visible = false
	_settings_menu.visible = false
	_quit_menu.visible = false

	# Создаем первую комнату и начинаем волны
	var first_room = _tilemap_generator.generate_next_room()
	add_room_trigger(first_room)
	_start_wave_spawning()

func add_room_trigger(room: Rect2i):
	var trigger = Area2D.new()
	trigger.set_collision_layer_value(1, false)
	trigger.set_collision_mask_value(1, false)
	trigger.set_collision_mask_value(3, true)
	trigger.set_collision_mask_value(4, true)
	var collision = CollisionPolygon2D.new()
	trigger.z_index = 1

	collision.polygon =  [
		room.position,
		room.position + Vector2i(room.size.x, 0),
		room.position + room.size,
		room.position + Vector2i(0, room.size.y)
	].map(func(side): return Vector2i(side.x - (room.position.x - room.position.y), side.y + (room.position.x - room.position.y))).map(_tilemap_generator.grid_to_world)
	
	trigger.add_child(collision)
	
	trigger.connect("area_entered", Callable(self, "_on_area_2d_area_entered"))
	trigger.connect("area_exited", Callable(self, "_on_area_2d_area_exited"))
	
	add_child(trigger)
	_triggers.append(trigger)

func destroy_previous_trigger() -> void:
	if _triggers.size() > 1:
		var previous_trigger: Area2D = _triggers.pop_front()
		if previous_trigger:
			for area in previous_trigger.get_overlapping_areas(): area.get_parent().queue_free()
			
			previous_trigger.queue_free()

func _start_wave_spawning() -> void:
	_can_spawn = true
	_is_wave_active = true
	_spawned_count = randi_range(_spawned_count_range.x, _spawned_count_range.y)
	_wave_count = randi_range(_wave_count_range.x, _wave_count_range.y)
	_current_wave = 0
	_start_next_wave()

func _start_next_wave() -> void:
	if _current_wave < _wave_count:
		_current_wave += 1
		_enemies_to_spawn_in_current_wave = randi_range(_spawned_count_in_wave_range.x, _spawned_count_in_wave_range.y)
		_enemy_spawn_timer.start(0.5)
	else:
		# Все волны завершены
		_is_wave_active = false

func _process(delta: float) -> void:
	if !_is_wave_active and get_tree().get_nodes_in_group("Enemy").size() == 0 and _triggers.size() < 2:
		# Сразу генерируем следующую комнату
		var new_room = _tilemap_generator.generate_next_room()
		add_room_trigger(new_room)
		
		var previous_trigger = _triggers.front()
		if previous_trigger:
			previous_trigger.disconnect("area_entered", Callable(self, "_on_area_2d_area_entered"))
			previous_trigger.disconnect("area_exited", Callable(self, "_on_area_2d_area_exited"))

func _spawn_enemy_in_wave() -> void:
	if _enemies_to_spawn_in_current_wave > 0 and _spawned_count > 0:
		_tilemap_spawner.spawn(1)
		_enemies_to_spawn_in_current_wave -= 1
		_spawned_count -= 1
		
		if _enemies_to_spawn_in_current_wave > 0 and _spawned_count > 0:
			_enemy_spawn_timer.start(randf_range(0.3, 0.8))
		else:
			_wave_delay_timer.start(randf_range(1.0, 2.0))

func _after_next_room() -> void:
	_tilemap_generator.destroy_previous_room()
	destroy_previous_trigger()
	
	var save_data := SaveData.new()
	save_data._player_health = _player_controller.health._health_current
	for weapon in _player_controller.equipment._weapons:
		save_data._weapons_scene_paths.append(weapon.scene_path)
	SaveLoad.save(save_data)
	
	_start_wave_spawning()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		_after_next_room_timer.start()
			
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		_after_next_room_timer.stop()
