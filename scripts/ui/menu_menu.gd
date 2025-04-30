extends Node2D


@export var hub: PackedScene


func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_packed(hub)


func _on_settings_pressed() -> void:
	pass # Replace with function body.
