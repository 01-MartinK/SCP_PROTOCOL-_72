extends VBoxContainer

func _ready() -> void:
	populate_areas()

func populate_areas() -> void:
	var files = get_files("res://assets/resources/areas/")
	
	for file in files:
		var area = load("res://assets/resources/areas/"+file)
		var btn = Button.new()
		btn.name = area.name + "_btn"
		btn.pressed.connect(func(): on_area_btn_clicked(area))
		btn.text = area.name
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(64, 64)
		get_node("area_panel/areas_group").add_child(btn)

func on_area_btn_clicked(area_type: AreaData) -> void:
	get_node("%areaManager").area_data = area_type

# get files from directory
func get_files(path) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while file != '':
		files += [file]
		file = dir.get_next()
	
	return files
