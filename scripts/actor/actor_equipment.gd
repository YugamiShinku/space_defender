class_name ActorEquipment extends Node2D

@export_range(0, 10, 1) var max_weapons := 2
@export var pickup_marker_front: Marker2D
@export var pickup_marker_back: Marker2D
@export var drop_marker: Marker2D

var _weapons: Array[Weapon] = []
var _current_weapons: Array[int] = []

func get_current_weapons() -> Array[Weapon]:
	var result: Array[Weapon] = []
	for i in _current_weapons:
		if i < _weapons.size():
			result.append(_weapons[i])
	return result

func drop_weapon(index: int) -> Weapon:
	if index < 0 or index >= _weapons.size():
		return null
	
	var weapon: Weapon = _weapons[index]
	_weapons.remove_at(index)
	
	# Обновляем индексы в _current_weapons
	for i in range(_current_weapons.size()):
		if _current_weapons[i] > index:
			_current_weapons[i] -= 1
		elif _current_weapons[i] == index:
			_current_weapons.remove_at(i)
			break
	
	weapon.get_parent().remove_child(weapon)
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = drop_marker.global_position
	weapon.set_pickable(true)
	
	# Если не осталось активных оружий, но есть другие - активируем последнее
	if _current_weapons.is_empty() && !_weapons.is_empty():
		_current_weapons = [_weapons.size() - 1]
	
	_update_weapon_visibility()
	return weapon

func drop_current_weapon() -> Weapon:
	if _weapons.is_empty():
		return null
	return drop_weapon(_weapons.size() - 1)


func pickup_weapon(weapon: Weapon) -> void:
	if _weapons.size() >= max_weapons:
		drop_weapon(0)  # Выбрасываем самое старое оружие
	
	weapon.get_parent().remove_child(weapon)
	pickup_marker_front.add_child(weapon)
	weapon.global_position = pickup_marker_front.global_position
	weapon.set_pickable(false)
	
	_weapons.append(weapon)
	
	# При подборе нового оружия делаем его активным
	_current_weapons = [_weapons.size() - 1]
	_update_weapon_visibility()

func switch_to_next_weapon() -> void:
	if _weapons.is_empty():
		return
	
	# Находим следующее неактивное оружие
	for i in range(_weapons.size()):
		var next_index = (_weapons.size() - 1 - i) % _weapons.size()
		if not _current_weapons.has(next_index):
			_current_weapons = [next_index]
			break
	
	_update_weapon_visibility()

func _update_weapon_visibility() -> void:
	for i in range(_weapons.size()):
		var weapon = _weapons[i]
		var is_active = _current_weapons.has(i)
		weapon.visible = is_active
		
		if is_active:
			# Определяем позицию активного оружия
			var position_in_active = _current_weapons.find(i)
			var marker = pickup_marker_front if position_in_active == 0 else pickup_marker_back
			
			if weapon.get_parent() != marker:
				weapon.reparent(marker)
			weapon.position = Vector2.ZERO
