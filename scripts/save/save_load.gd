extends Node2D

const SAVE_GAME_PATH := "user://save_load.tres"

var _save_data := SaveData.new()

func save(save_data: SaveData) -> void:
	ResourceSaver.save(save_data, SAVE_GAME_PATH)
	_save_data = save_data
	
func load_data() -> SaveData:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		_save_data = ResourceLoader.load(SAVE_GAME_PATH).duplicate(true)
		return _save_data
	return null

func delete() -> void:
	var dir = DirAccess.open("user://")
	dir.remove(SAVE_GAME_PATH)
	_save_data = SaveData.new()
