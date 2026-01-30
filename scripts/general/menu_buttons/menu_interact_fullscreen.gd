extends MenuInteract

@onready var text_label: Label = $Value
var is_window: bool

func interact() -> void:
	var mode := DisplayServer.window_get_mode()
	is_window = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	change_text(	)

func change_text() -> void:
	if is_window:
		text_label.text = "FULLSCREEN"
	else:
		text_label.text = "WINDOWED"
