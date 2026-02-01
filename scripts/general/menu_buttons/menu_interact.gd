extends Panel
class_name MenuInteract

func interact() -> void:
	pass

func left() -> void:
	pass

func right() -> void:
	pass

func on_selected() -> void:
	get_theme_stylebox("panel").border_color = Color.from_rgba8(255, 255, 255, 255)

func on_deselected() -> void:
	get_theme_stylebox("panel").border_color = Color.from_rgba8(0, 0, 0, 255)
