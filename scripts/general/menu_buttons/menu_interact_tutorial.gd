extends MenuInteract

@onready var text_label: Label = $Value

signal start_tutorial

func interact() -> void:
	start_tutorial.emit()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)
