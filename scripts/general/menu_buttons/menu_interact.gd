extends Panel
class_name MenuInteract

const texture_deselected = preload("uid://bvgoaq8jknutp")
const texture_selected = preload("uid://l0as8sern610")


func interact() -> void:
	pass

func left() -> void:
	pass

func right() -> void:
	pass

func on_selected() -> void:
	get_theme_stylebox("panel").texture = texture_selected

func on_deselected() -> void:
	get_theme_stylebox("panel").texture = texture_deselected
