extends MenuInteract

@onready var text_label: Label = $Value

signal quit_game

func interact() -> void:
	quit_game.emit()
