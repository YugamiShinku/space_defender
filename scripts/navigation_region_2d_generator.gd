extends NavigationRegion2D

@export var auto_bake_on_ready: bool = true
@export var collision_mask: int = 1
@export var root_node: Node

func _ready():
	if auto_bake_on_ready:
		bake_from_scene()

func bake_from_scene():
	var geometry = NavigationMeshSourceGeometryData2D.new()
	
	# Сбор геометрии со сцены
	NavigationServer2D.parse_source_geometry_data(
		navigation_polygon,
		geometry,
		root_node
		#get_tree().root,
	)
	
	# Выпечка
	NavigationServer2D.bake_from_source_geometry_data(
		navigation_polygon,
		geometry
	)
	
	# Обновление региона
	navigation_polygon = navigation_polygon.duplicate()
