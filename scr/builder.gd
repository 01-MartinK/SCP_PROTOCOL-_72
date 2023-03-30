extends CharacterBody3D

enum STATES { ACTION, BUILDING, AREA, CONTROL }
var state : STATES = STATES.ACTION

@onready var grid_map: GridMap = get_parent().get_node("GridMap")
@onready var floor_grid_map: GridMap = get_parent().get_node("floor_gridMap")

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var cam: Camera3D = $SpringArm3D/Camera3D

@onready var build_manager: Node = $buildManager
@onready var area_manager: Node = $areaManager
@onready var control_manager: Node = $controlManager

@onready var cursor: Node3D = $cursor

var move_speed = 8

var selected = null

var menu = null

func _ready() -> void:
	build_manager.active = false
	area_manager.active = false
	control_manager.active = false

func _process(delta: float) -> void:
	
	checkMovement()
	
	if state == STATES.ACTION:
		var mouse_collision = get_intersection_with_collision_layer(112)
		
		if Input.is_action_just_pressed("mouse_primary"):
			if mouse_collision:
				select_object(mouse_collision.collider)
			elif selected != null:
				unselect_object()
		if Input.is_action_just_pressed("mouse_secondary"):
			var mouse_collision_second = get_intersection()
			if mouse_collision_second:
				if selected != null && selected.is_in_group("personal"):
					#selected.set_target_position(mouse_collision_second.position)
					if menu != null:
						menu.queue_free()
					
					menu = PopupMenu.new()
					menu.add_item("Work")
					menu.add_item("Move")
					menu.add_item("Cancel")
					menu.position = get_viewport().get_mouse_position()
					menu.popup_hide.connect(Callable(func(): menu.queue_free()))
					menu.index_pressed.connect(Callable(self, "menu_item_pressed"))
					add_child(menu)
					menu.popup()

# select the object that is clicked
func select_object(selected_object) -> void:
	if selected_object.is_in_group("personal"):
		if selected != null or selected == selected_object:
			selected.get_node("selector_mesh").hide()
			selected = null
		else:
			selected = selected_object
			selected.get_node("selector_mesh").show()
	
	if selected_object.is_in_group("has_popup"):
		selected_object.show_popup()

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

func check_ui_collision() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var ui_component_rects : Array[Rect2]= []
	
	return false

# menu item pressed
func menu_item_pressed(index: int) -> void:
	print(index)
