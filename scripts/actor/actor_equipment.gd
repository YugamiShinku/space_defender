class_name ActorEquipment extends Node2D

@export_range(0, 10, 1) var max_weapons := 2
@export var pickup_marker: Marker2D
@export var drop_marker: Marker2D

var _weapons: Array[Weapon] = []
var _current_weapon_i := -1

func get_current_weapon() -> Weapon:
	if _current_weapon_i == -1: return null
	return _weapons[_current_weapon_i]

func drop_current_weapon() -> Weapon:
	if _current_weapon_i == -1: return
	
	var weapon: Weapon = _weapons.pop_at(_current_weapon_i)
	weapon.get_parent().remove_child(weapon)
	get_tree().current_scene.add_child(weapon)
	
	weapon.global_position = drop_marker.global_position
	weapon.set_pickable(true)

	if _weapons.is_empty(): _current_weapon_i = -1
	else: _current_weapon_i = _weapons.size() - 1
	
	_update_weapon_visibility()
	
	return weapon

func pickup_weapon(weapon: Weapon) -> void:
	if _weapons.size() >= max_weapons: drop_current_weapon()
	
	weapon.get_parent().remove_child(weapon)
	pickup_marker.add_child(weapon)
	
	weapon.global_position = pickup_marker.global_position
	weapon.set_pickable(false)

	_weapons.append(weapon)
	
	_current_weapon_i = _weapons.size() - 1
	_update_weapon_visibility()

func switch_to_next_weapon() -> void:
	if _current_weapon_i == -1: return
	
	_current_weapon_i = (_current_weapon_i + 1) % _weapons.size()
	_update_weapon_visibility()

func _update_weapon_visibility() -> void:
	for i in range(_weapons.size()):
		_weapons[i].visible = (i == _current_weapon_i)
