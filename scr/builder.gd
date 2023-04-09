extends CharacterBody3D

enum STATES { ACTION, BUILDING, AREA, CONTROL }
var state : STATES = STATES.ACTION

@onready var grid_map: GridMap = get_parent().get_node("GridMap")
@onready var floor_grid_map: GridMap = get_parent().get_node("floor_gridMap")

#@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var cam: Camera3D = $SpringArm3D/Camera3D

@onready var build_manager: Node = $buildManager
@onready var area_manager: Node = $areaManager
@onready var control_manager: Node = $controlManager

@onready var cursor: Node3D = $cursor

@onready var ui: CanvasLayer = $CanvasLayer

var move_speed = 8

var selected = null

func _ready() -> void:
	build_manager.active = false
	area_manager.active = false
	control_manager.active = false

func _process(_delta: float) -> void:
	
	checkMovement()
	
	if state == STATES.ACTION:
		var mouse_collision = get_intersection_with_collision_layer(112)
		
		if Input.is_action_just_pressed("mouse_primary"):
			if mouse_collision:
				select_object(mouse_collision.collider)
			elif selected != null:
				unselect_object()

# select the object that is clicked
func select_object(selected_object) -> void:
	# check if selected object is in the personal group
	if selected_object.is_in_group("personal"):
		# check if object is selected or not
		if selected != null or selected == selected_object:
			selected.get_node("selector_mesh").hide()
			ui.get_node("personalProfile").hide()
			selected = null
		else:
			selected = selected_object
			selected.get_node("selector_mesh").show()
			ui.get_node("personalProfile").popup()
			ui.get_node("personalProfile").position = Vector2(916,220)
	elif selected_object is Area3D: # if selected object is an area
		ui.get_node("area_popup").update_data(selected_object.data)
		ui.get_node("area_popup").position = get_viewport().get_mouse_position()
		ui.get_node("area_popup").popup()

# unselect that object that was clicked
func unselect_object() -> void:
	if selected.has_node("selector_mesh"):
		selected.get_node("selector_mesh").hide()
	
	selected = null

# check for camera movement
func checkMovement() -> void:
	var InputDir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = Vector3(InputDir.x, 0, InputDir.y) * move_speed
	
	move_and_slide()

# switch state
func _switch_state(new_state : STATES) -> void:
	if new_state != state:
		state = new_state
		
		build_manager.active = (new_state == STATES.BUILDING)
		area_manager.active = (new_state == STATES.AREA)
		control_manager.active = (new_state == STATES.CONTROL)

# get intersection
func get_intersection() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	
	# space state
	var space_state = get_world_3d().direct_space_state
	
	# ray positions
	var ray_origin : Vector3
	var ray_end : Vector3
	
	# get rays
	ray_origin = cam.project_ray_origin(mouse_pos)
	ray_end = ray_origin + cam.project_ray_normal(mouse_pos) * 2000
	
	# set intersection ray
	var intersection_ray = PhysicsRayQueryParameters3D.new()
	intersection_ray.from = ray_origin
	intersection_ray.to = ray_end
	
	var intersection = space_state.intersect_ray(intersection_ray)
	
	return intersection

# get intersection but with a collision mask
func get_intersection_with_collision_layer(mask_int: int) -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	
	# space state
	var space_state = get_world_3d().direct_space_state
	
	# ray positions
	var ray_origin : Vector3
	var ray_end : Vector3
	
	# get rays
	ray_origin = cam.project_ray_origin(mouse_pos)
	ray_end = ray_origin + cam.project_ray_normal(mouse_pos) * 2000
	
	# set intersection ray
	var intersection_ray = PhysicsRayQueryParameters3D.new()
	intersection_ray.from = ray_origin
	intersection_ray.to = ray_end
	intersection_ray.collision_mask = mask_int
	intersection_ray.collide_with_areas = true
	
	var intersection = space_state.intersect_ray(intersection_ray)
	
	return intersection

# check if mouse is on ui
func check_mouse_ui_click() -> bool:
	return get_node("CanvasLayer").check_if_mouse_ui()
