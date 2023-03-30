extends Node

@onready var cursor: Node3D = $"../cursor"
@onready var area_prefab: PackedScene = preload("res://objects/area.tscn")

var active: bool = false :
	set(value):
		set_process(value)
		cursor.get_node("areaCursor").visible = value
		active = value

var grid: float = 0.5
var placing: bool = false

var start_pos: Vector3
var end_pos: Vector3

var offset = Vector3(0.25, 0, 0.25)

var area_data: AreaData = load("res://assets/resources/areas/d_class_cell.tres")

func _ready() -> void:
	set_process(active)

func _process(delta: float) -> void:
	var mouse_collision: Dictionary = get_parent().get_intersection()
	
	# if there is an intersection at the scene
	if mouse_collision:
		var grid_pos = Vector3(floor(mouse_collision.position.x/grid)*grid, 0, floor(mouse_collision.position.z/grid)*grid) + offset
		
		if placing:
			var distance_towards_x_axis: float = grid_pos.distance_to(Vector3(start_pos.x, 0, grid_pos.z))
			var distance_towards_z_axis: float = grid_pos.distance_to(Vector3(grid_pos.x, 0, start_pos.z)) 
			
			cursor.global_position = (start_pos + Vector3(grid_pos.x, 0, grid_pos.z)) / 2
			cursor.get_node("areaCursor").mesh.size = Vector3(distance_towards_x_axis + grid, 0.1, distance_towards_z_axis + grid)
		else:
			cursor.get_node("areaCursor").mesh.size = Vector3(grid, 0.1, grid)
			cursor.global_position = grid_pos
		
		if Input.is_action_just_pressed("mouse_primary"):
			placing = true
			start_pos = grid_pos
			cursor.get_node("areaCursor").mesh.material.albedo_color = Color(0,0.75,0,0.5)
		elif Input.is_action_just_released("mouse_primary"):
			placing = false
			end_pos = grid_pos
			place_area(start_pos, end_pos, cursor.get_node("areaCursor").mesh.size)
		
		if Input.is_action_just_pressed("mouse_secondary"):
			placing = true
			start_pos = grid_pos
			cursor.get_node("areaCursor").mesh.material.albedo_color = Color(0.75,0.25,0.25,0.5)
		elif Input.is_action_just_released("mouse_secondary"):
			placing = false
			end_pos = grid_pos

func place_area(start: Vector3,end: Vector3, scale: Vector3) -> void:
	var b = area_prefab.instantiate()
	
	b.position = (start + end) / 2
	b.set_area_name(area_data.name)
	b.set_size(scale.x, scale.z)
	b.data = area_data
	b.update_values()
	
	get_parent().get_parent().get_node("areas").add_child(b)

func delete_area() -> void:
	pass

func select_area() -> void:
	pass
