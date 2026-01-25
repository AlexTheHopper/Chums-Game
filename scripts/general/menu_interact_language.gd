extends MenuInteract

@onready var text_label: Label = $Value

signal select_language

var languages = ["english", "spanish", "simlish"]
var index = 0

func left() -> void:
	index -= index
	if index < 0:
		index = languages.size() - 1
	text_label.text = languages[index]

func right() -> void:
	index += 1
	if index > languages.size() - 1:
		index = 0
	text_label.text = languages[index]

func interact() -> void:
	pass #TODO This is where you would change the language

func initialise() -> void:
	text_label.text = languages[index]
