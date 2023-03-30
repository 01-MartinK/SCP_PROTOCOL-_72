extends HBoxContainer

@onready var build_manager: Node = %buildManager

func _ready() -> void:
	spawn_wall_items()
	spawn_floor_items()
	spawn_furniture_items()

func spawn_wall_items() -> void:
	var file_paths = get_files("res://assets/resources/walls/")
	for path in file_paths:
		var file = load("res://assets/resources/walls/"+path)
		var btn = Button.new()
		btn.name = file.name + "_btn"
		btn.pressed.connect(func(): on_item_clicked(file))
		btn.text = file.name
		btn.custom_minimum_size = Vector2(64, 64)
		get_node("wall_items_group/Walls").add_child(btn)

func spawn_floor_items() -> void:
	var file_paths = get_files("res://assets/resources/floors/")
	for path in file_paths:
		var file = load("res://assets/resources/floors/"+path)
		var btn = Button.new()
		btn.name = file.name + "_btn"
		btn.pressed.connect(func(): on_item_clicked(file))
		btn.text = file.name
		btn.custom_minimum_size = Vector2(64, 64)
		get_node("floor_items_group/Floors").add_child(btn)

func spawn_furniture_items() -> void:
	var file_paths = get_files("res://assets/resources/furniture/")
	for path in file_paths:
		var file = load("res://assets/resources/furniture/"+path)
		var btn = Button.new()
		btn.name = file.name + "_btn"
		btn.pressed.connect(func(): on_furniture_clicked(file))
		btn.text = file.name
		btn.custom_minimum_size = Vector2(64, 64)
		get_node("furniture_items_group/All").add_child(btn)

# when a floor or wall
func on_item_clicked(item) -> void:
	build_manager.building_type = item.type_int

# when a furniture button pressed
func on_furniture_clicked(item) -> void:
	build_manager.get_node("furnitureManager").set_furniture(item)

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
