extends Node2D

@export var hub_scene: PackedScene

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(hub_scene)

func _on_settings_pressed() -> void:
	pass
