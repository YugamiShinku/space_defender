extends Node2D

const SAVE_GAME_PATH := "user://save_load.tres"

func save(save_data: SaveData) -> void:
	ResourceSaver.save(save_data, SAVE_GAME_PATH)
	
func load_data() -> SaveData:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH).duplicate(true)
	return null

func delete() -> void:
	var dir = DirAccess.open("user://")
	dir.remove(SAVE_GAME_PATH)
