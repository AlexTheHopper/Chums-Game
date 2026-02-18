extends MenuInteract

@onready var text_label: Label = $Value

signal move_to_menu

func interact() -> void:
	move_to_menu.emit(0)
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)
