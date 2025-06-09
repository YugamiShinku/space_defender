class_name Director extends Node2D

@onready var _tilemap_generator: TileMapGenerator = $"Tilemap Generator"
@onready var _player_contoller: PlayerController = $"Player Controller"
@onready var _tilemap_spawner: TilemapSpawner = $"Tilemap Spawner"
@onready var _main_menu: MainMenu = $"MainMenu"
@onready var _game_menu: GameMenu = $"GameMenu"
@onready var _pause_menu: PauseMenu = $"PauseMenu"
@onready var _settings_menu: SettingsMenu = $"SettingsMenu"
@onready var _quit_menu: QuitMenu = $"QuitMenu"
@onready var _environment_audio: AudioStreamPlayer2D = $"AudioStreamPlayer2D"

var _spawned_count_range := Vector2i(6,9)
var _spawned_count_in_wave_range := Vector2i(1,3)
var _spawned_count := 0
var _wave_count_range := Vector2i(1, 1)
var _wave_count := 0
var _current_wave := -1

func _ready() -> void:
	get_tree().paused = true
	_environment_audio.play()
	_game_menu.set_visibility(true)
	_game_menu.set_visibility(false)
	_pause_menu.set_visibility(false)
	_settings_menu.set_visibility(false)
	_quit_menu.set_visibility(false)
	
	_tilemap_generator.generate_next_room()
	
func _process(delta: float) -> void:
	if _tilemap_spawner.is_spawned_not_exists() and _current_wave < _wave_count:
		if _wave_count == 0:
			_wave_count = randi_range(_wave_count_range.x, _wave_count_range.y)
		_spawned_count = randi_range(_spawned_count_range.x, _spawned_count_range.y)
		_current_wave += 1
		
	if _tilemap_spawner.spawned_count() <= 2:
		var spawned_count_in_wave = clamp(randi_range(_spawned_count_in_wave_range.x, _spawned_count_in_wave_range.y), 1, _spawned_count)
		_tilemap_spawner.spawn(spawned_count_in_wave)
		_spawned_count -= spawned_count_in_wave
		
	if _current_wave >= _wave_count:
		_tilemap_generator.generate_next_room()
		_wave_count = randi_range(_wave_count_range.x, _wave_count_range.y)
		_current_wave = 0
		
