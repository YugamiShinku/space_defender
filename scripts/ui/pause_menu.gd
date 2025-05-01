extends Control


@export var main_menu_scene: PackedScene

func _on_quit_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_resume_pressed() -> void:
	pass

func _on_settings_pressed() -> void:
	pass
