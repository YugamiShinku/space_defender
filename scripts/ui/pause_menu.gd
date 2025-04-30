extends Control


@export var main_menu: PackedScene


func _on_quit_pressed():
	get_tree().change_scene_to_packed(main_menu)


func _on_resume_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.
