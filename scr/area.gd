extends Area3D

var data: AreaData
var has_all_requirements_filled: bool = false

func _ready() -> void:
	add_to_group("area")
	add_to_group("has_popup")

func update_values() -> void:
	set_area_name(data.name)

func set_area_name(new_name: String) -> void:
	get_node("Label3D").text = new_name

func set_size(x_scale: float, y_scale: float) -> void:
	get_node("MeshInstance3D").mesh.size = Vector2(x_scale, y_scale)
	get_node("CollisionShape3D").shape.size = Vector3(x_scale, 0.1, y_scale)
	if x_scale < 1.5:
		get_node("Label3D").pixel_size = x_scale / 100
	else:
		get_node("Label3D").pixel_size = 0.01

func check_requirements() -> void:
	pass
