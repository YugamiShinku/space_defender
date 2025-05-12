class_name ActorEquipment extends Node2D

@export var max_weapons: int = 2
@export var pickup_marker: Marker2D
@export var drop_marker: Marker2D

var _weapons: Array[Weapon] = []
var _current_weapon_i: int = -1

func get_current_weapon() -> Weapon:
	if _current_weapon_i == -1: return null
	return _weapons[_current_weapon_i]

func drop_current_weapon() -> void:
	if _current_weapon_i == -1: return
	
	var weapon = _weapons.pop_at(_current_weapon_i)
	weapon.get_parent().remove_child(weapon)
	get_tree().current_scene.add_child(weapon)
	
	weapon.global_position = drop_marker.global_position
	weapon.setup_pickable(true)

	if _weapons.is_empty(): _current_weapon_i = -1
	else: _current_weapon_i = _weapons.size() - 1
	
	_update_weapon_visibility()

func pickup_weapon(weapon: Node2D) -> void:
	if _weapons.size() >= max_weapons: drop_current_weapon()
	
	weapon.get_parent().remove_child(weapon)
	pickup_marker.add_child(weapon)
	
	weapon.global_position = pickup_marker.global_position
	weapon.setup_pickable(false)

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
