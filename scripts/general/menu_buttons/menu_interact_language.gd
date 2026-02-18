extends MenuInteract

@onready var text_label: Label = $Value

signal select_language

var languages = ["en_US", "es_ES", "de_DE", "ca_ES", "it_IT", "fr_FR", "ro_RO", "jp_JP", "cn_CN"]
var index = 0

func _ready() -> void:
	index = languages.find(SaverLoader.game_settings["selected_language"])
	TranslationServer.set_locale(languages[index])
	select_language.emit(languages[index])

func left() -> void:
	index -= 1
	if index < 0:
		index = languages.size() - 1
	change_language(languages[index])
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)

func right() -> void:
	index += 1
	if index > languages.size() - 1:
		index = 0
	change_language(languages[index])
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)

func change_language(lan_code: String) -> void:
	TranslationServer.set_locale(lan_code)
	SaverLoader.game_settings["selected_language"] = lan_code
	SaverLoader.save_gamestate()
	select_language.emit(lan_code)
