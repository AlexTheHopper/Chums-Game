extends Control
class_name ButtonsGroup

var buttons := []

func _ready() -> void:
	for child in get_children():
		buttons.append(child)
