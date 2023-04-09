extends CharacterBody3D

enum STATES {IDLE, MOVE, WORK}
var state: STATES = STATES.IDLE

@onready var navAgent: NavigationAgent3D = get_node("NavigationAgent3D")

const SPEED = 1.95

var move_vec: Vector3 = Vector3.ZERO
var extra_movement: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("personal")
	navAgent.target_reached.connect(Callable(self, "target_reached"))

func _physics_process(_delta: float) -> void:
	if navAgent.is_target_reachable() and !navAgent.is_target_reached():
		var next_pos = navAgent.get_next_path_position()
		move_vec = global_position.direction_to(next_pos) * SPEED
	
	
	
	if velocity.length() > 0.1:
		var look_rot = Vector2(move_vec.x, -move_vec.z).angle() + deg_to_rad(90)
		$body.rotation.y = lerp_angle($body.rotation.y, look_rot, 0.15)
		$rays.rotation.y = look_rot
	
	check_extra_rays()
	
	velocity = move_vec + extra_movement
	
	move_and_slide()

func target_reached() -> void:
	move_vec = Vector3.ZERO

func set_target_position(pos: Vector3) -> void:
	navAgent.set_target_position(pos)
	print("New pos")

func check_extra_rays() -> void:
	if get_node("rays/left_ray").is_colliding():
		extra_movement = -global_transform.basis.x * SPEED
	elif get_node("rays/right_ray").is_colliding():
		extra_movement = -global_transform.basis.x * SPEED
	else:
		extra_movement.x = 0
