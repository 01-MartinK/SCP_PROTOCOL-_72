extends Node

enum PlACEMENT_TYPES {WALLS,FLOORS}
var placement: PlACEMENT_TYPES = PlACEMENT_TYPES.WALLS

@onready var cursor: Node3D = $"../cursor"

var active: bool = false :
	set(value):
		set_process(value)
		cursor.get_node("buildingCursor").visible = value
		active = value
		if value == false:
			get_child(0).active = false
			get_child(0).furniture = null

var grid: float = 0.5

var placing: bool = false
var furniture = null

var start_pos: Vector3
var end_pos: Vector3

var mesh_size: Vector3 = Vector3(0.5, 1, 0.5)
var offset = Vector3(0.25, 0, 0.25)

var building_type: int = 0

func _ready() -> void:
	set_process(false)
	get_node("%build_menu/button_group/walls_btn").connect("pressed", Callable(self, "onWallsButtonPressed"))
	get_node("%build_menu/button_group/floor_btn").connect("pressed", Callable(self, "onFloorsButtonPressed"))
	get_node("%build_menu/button_group/furniture_btn").connect("pressed", Callable(self, "onFurnitureButtonPressed"))

func onWallsButtonPressed() -> void:
	building_type = 0
	switch_placement_type(PlACEMENT_TYPES.WALLS)
	active = true
	get_child(0).active = false

func onFloorsButtonPressed() -> void:
	building_type = 0
	switch_placement_type(PlACEMENT_TYPES.FLOORS)
	active = true
	get_child(0).active = false

func onFurnitureButtonPressed() -> void:
	active = false
	get_child(0).active = true
	get_node("%build_menu").get_node("wall_items_group").hide()
	get_node("%build_menu").get_node("floor_items_group").hide()
	get_node("%build_menu").get_node("furniture_items_group").show()

func _process(delta: float) -> void:
	var mouse_collision = get_parent().get_intersection()
	
	# check if mouse is colliding floor
	if mouse_collision:
		var grid_pos = Vector3(floor(mouse_collision.position.x/grid)*grid, 0, floor(mouse_collision.position.z/grid)*grid) + offset
		
		if placing:
			if placement == PlACEMENT_TYPES.WALLS: # placement for walls
				var distance_towards_x_axis: float = grid_pos.distance_to(Vector3(start_pos.x, 0, grid_pos.z))
				var distance_towards_z_axis: float = grid_pos.distance_to(Vector3(grid_pos.x, 0, start_pos.z)) 
				
				# check which direction the cursor is in
				if distance_towards_x_axis > distance_towards_z_axis:
					#print(start_pos.distance_to(Vector3(grid_pos.x, 0, start_pos.z)))
					cursor.global_position = (start_pos + Vector3(grid_pos.x, 0, start_pos.z)) / 2
					cursor.get_node("buildingCursor").mesh.size = Vector3(distance_towards_x_axis + grid, mesh_size.y, grid)
					end_pos = Vector3(grid_pos.x, 0, start_pos.z)
				elif distance_towards_z_axis > distance_towards_x_axis:
					#print(start_pos.distance_to(Vector3(start_pos.x, 0, grid_pos.z)))
					cursor.global_position = (start_pos + Vector3(start_pos.x, 0, grid_pos.z)) / 2
					cursor.get_node("buildingCursor").mesh.size = Vector3(grid, mesh_size.y, distance_towards_z_axis + grid)
					end_pos = Vector3(start_pos.x, 0, grid_pos.z)
				
			elif placement == PlACEMENT_TYPES.FLOORS: # placement for floors
				cursor.global_position = (start_pos + grid_pos) / 2
				end_pos = Vector3(grid_pos.x, 0, grid_pos.z)
				
				var distance_towards_x_axis: float = grid_pos.distance_to(Vector3(start_pos.x, 0, grid_pos.z))
				var distance_towards_z_axis: float = grid_pos.distance_to(Vector3(grid_pos.x, 0, start_pos.z)) 
				cursor.get_node("buildingCursor").mesh.size = Vector3(distance_towards_x_axis + grid/2, mesh_size.y, distance_towards_z_axis + grid/2)
		else:
			# reset stuff
			cursor.get_node("buildingCursor").mesh.size = mesh_size
			cursor.global_position = grid_pos
		
		# build click
		if Input.is_action_just_pressed("mouse_primary"):
			placing = true
			start_pos = grid_pos
			end_pos = grid_pos
			cursor.get_node("buildingCursor").mesh.material.albedo_color = Color(0,0.75,0,0.5)
		elif Input.is_action_just_released("mouse_primary"):
			if placement == PlACEMENT_TYPES.WALLS:
				build_walls(start_pos, end_pos, building_type)
			elif placement == PlACEMENT_TYPES.FLOORS:
				build_floor(Vector3(start_pos.x, 0, start_pos.z), end_pos, building_type)
			placing = false
		
		# deletion click
		if Input.is_action_just_pressed("mouse_secondary"):
			placing = true
			start_pos = grid_pos
			end_pos = grid_pos
			cursor.get_node("buildingCursor").mesh.material.albedo_color = Color(0.75,0.25,0.25,0.5)
		elif Input.is_action_just_released("mouse_secondary"):
			if placement == PlACEMENT_TYPES.WALLS:
				build_walls(start_pos, end_pos, -1)
			elif placement == PlACEMENT_TYPES.FLOORS:
				build_floor(Vector3(start_pos.x, 0, start_pos.z), end_pos, -1)
			placing = false

# switch placement type
func switch_placement_type(new_type: PlACEMENT_TYPES) -> void:
	if placement != new_type:
		placement = new_type
		
		if placement == PlACEMENT_TYPES.WALLS:
			get_node("%build_menu").get_node("wall_items_group").show()
			get_node("%build_menu").get_node("floor_items_group").hide()
			get_node("%build_menu").get_node("furniture_items_group").hide()
			grid = 0.5
			mesh_size = Vector3(0.5, 1, 0.5)
			offset = Vector3(0.25, 0, 0.25)
		elif placement == PlACEMENT_TYPES.FLOORS:
			get_node("%build_menu").get_node("wall_items_group").hide()
			get_node("%build_menu").get_node("floor_items_group").show()
			get_node("%build_menu").get_node("furniture_items_group").hide()
			grid = 0.5
			mesh_size = Vector3(0.5, 0.1, 0.5)
			offset = Vector3(0.25, -0.5, 0.25)

func build_floor(start: Vector3, end: Vector3, type: int = 0) -> void: 
	var grid_map = get_parent().floor_grid_map
	var x_distance = start.distance_to(Vector3(end.x, 0, start.z)) + 0.5
	var y_distance = start.distance_to(Vector3(start.x, 0, end.z)) + 0.5
	
	var x_direction = start.direction_to(Vector3(end.x, 0, start.z))
	var y_direction = start.direction_to(Vector3(start.x, 0, end.z))
	
	var i = 0
	while i < x_distance:
		var j = 0
		
		while j < y_distance:
			var grid_pos: Vector3i = grid_map.local_to_map(Vector3(start.x, 0, start.z) + (x_direction * i) + (y_direction * j)) 
			grid_map.set_cell_item(grid_pos, type)
			
			j += 0.5
		
		i += 0.5

# build the walls via straight algorithm
func build_walls(start: Vector3, end: Vector3, type: int = 0) -> void:
	var grid_map = get_parent().grid_map
	var distance = start.distance_to(end) + 0.5
	
	var direction_pos = start.direction_to(end)
	
	var i = 0
	while i < distance:
		var grid_pos: Vector3i = grid_map.local_to_map(Vector3(start.x, start.y, start.z) + (direction_pos * i))
		grid_map.set_cell_item(grid_pos, type)
		i += 0.5
