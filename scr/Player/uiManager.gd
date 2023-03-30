extends CanvasLayer

func _ready() -> void:
	get_node("%main_button_group").get_node("build_btn").connect("pressed", Callable(self, "_buildBtnPressed"))
	get_node("%main_button_group").get_node("area_btn").connect("pressed", Callable(self, "_areaBtnPressed"))
	get_node("%build_menu").get_child(0).get_node("build_btn").connect("pressed", Callable(self, "_closeBtnPressed"))
	get_node("%area_menu").get_child(1).get_node("close_btn").connect("pressed", Callable(self, "_closeBtnPressed"))

# on build button pressed
func _buildBtnPressed() -> void:
	showMenu(1)
	get_parent()._switch_state(get_parent().STATES.BUILDING)

# on area button pressed
func _areaBtnPressed() -> void:
	showMenu(2)
	get_parent()._switch_state(get_parent().STATES.AREA)

# on control button pressed
func _controlBtnPressed() -> void:
	pass

# on close btn pressed
func _closeBtnPressed() -> void:
	showMenu(0)
	get_parent()._switch_state(get_parent().STATES.ACTION)

# show a specific menu
func showMenu(i: int) -> void:
	if i == 0:
		get_node('%main_button_group').show()
		get_node('%build_menu').hide()
		get_node('%area_menu').hide()
	elif i == 1:
		get_node('%main_button_group').hide()
		get_node('%build_menu').show()
		get_node('%area_menu').hide()
	elif i == 2:
		get_node('%main_button_group').hide()
		get_node('%build_menu').hide()
		get_node('%area_menu').show()
