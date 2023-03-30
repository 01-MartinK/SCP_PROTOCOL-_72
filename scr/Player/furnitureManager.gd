extends Node

@onready var cursor: Node3D = $'../../cursor'

var grid_size: Vector2 = Vector2(0.5, 1)
var rotated_grid: Vector2 = grid_size
var rotation_amount: float = 0
var offset: Vector3 = Vector3(0, 0, 0)
var can_place: bool = true

var furniture: FurnitureData = null

var active: bool = false:
	set(value):
		active = value
		cursor.get_node("furniture").visible = value
		set_process(value)

func _ready() -> void:
	set_process(active)

func _process(_delta: float) -> void:
	var mouse_collision = get_parent().get_parent().get_intersection()
	
	if Input.is_action_just_pressed("rotate_left"):
		rotation_amount += 90
	elif Input.is_action_just_pressed("rotate_right"):
		rotation_amount -= 90
	
	rotated_grid = grid_size.rotated(deg_to_rad(rotation_amount))
	cursor.get_node("furniture").rotation.y = deg_to_rad(rotation_amount)
	
	if mouse_collision:
		var grid_pos = Vector3(floor(mouse_collision.position.x/rotated_grid.x)*rotated_grid.x, 0, floor(mouse_collision.position.z/rotated_grid.y)*rotated_grid.y) + Vector3(rotated_grid.x / 2, 0, rotated_grid.y / 2)
		
		if Input.is_action_just_pressed("mouse_primary"):
			if furniture != null:
				place_furniture(grid_pos)
		
		cursor.global_position = grid_pos

func place_furniture(pos: Vector3) -> void:
	var b = furniture.scene.instantiate()
	b.position = pos
	b.rotation.y = deg_to_rad(rotation_amount)
	get_parent().get_parent().get_parent().get_node("props").add_child(b)

func set_furniture(new_furniture) -> void:
	furniture = new_furniture
	grid_size = furniture.grid_size
	cursor.get_node("furniture").mesh = furniture.mesh
