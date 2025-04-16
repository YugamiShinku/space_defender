extends Control



func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)
	


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
