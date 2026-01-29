extends MenuInteract

@onready var text_label: Label = $Value

signal select_language

var languages = ["en", "es", "de", "ca", "it", "fr", "ro", "jp", "ch"]
var index = 0

func left() -> void:
	index -= 1
	if index < 0:
		index = languages.size() - 1
	change_language(languages[index])

func right() -> void:
	index += 1
	if index > languages.size() - 1:
		index = 0
	change_language(languages[index])

func interact() -> void:
	pass #TODO This is where you would change the language

func change_language(lan_code: String) -> void:
	TranslationServer.set_locale(lan_code)
	select_language.emit(lan_code)
