extends Node

var active: bool = false:
	set(value):
		active = value
		set_process(value)

func _ready() -> void:
	set_process(active)
