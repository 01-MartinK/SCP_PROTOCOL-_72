extends Popup

var area: Area3D = null
var requirement_fullfilled = false

func _ready() -> void:
	popup()

func update_data(new_data: AreaData) -> void:
	$Control/Panel/VBoxContainer/area_name.text = new_data.name
	$Control/Panel/VBoxContainer/description.text = new_data.description
	fill_requirements_list(new_data.furniture_requirements)

func fill_requirements_list(list: Array) -> void:
	clear_requirements_list()
	for req in list:
		var lbl = Label.new()
		lbl.text = req.name
		lbl.add_theme_color_override("font_color", Color.RED)
		$Control/Panel/VBoxContainer/requirements.add_child(lbl)

func clear_requirements_list() -> void:
	for child in $Control/Panel/VBoxContainer/requirements.get_children():
		child.queue_free()

func _on_popup_hide() -> void:
	queue_free()

func _on_destroy_btn_pressed() -> void:
	area.queue_free()
	queue_free()
