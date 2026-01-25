extends MenuInteract

@onready var text_label: Label = $Value

signal start_tutorial

func interact() -> void:
	start_tutorial.emit()

func initialise() -> void:
	text_label.text = "Tutorial"
