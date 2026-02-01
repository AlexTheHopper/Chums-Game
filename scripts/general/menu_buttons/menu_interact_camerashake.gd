extends MenuInteract

var index := 2
@onready var text_label: Label = $Value
@onready var texture : TextureRect = $TextureRect
@onready var shake_images := {
	0: preload("res://assets/menu_icons/icon_camerashake0.png"),
	1: preload("res://assets/menu_icons/icon_camerashake1.png"),
	2: preload("res://assets/menu_icons/icon_camerashake2.png"),
}

func _ready() -> void:
	index = SaverLoader.game_settings["camera_shake"]
	if index not in shake_images.keys():
		index = 2
	change_shake(false)

func left() -> void:
	index = max(0, index - 1)
	change_shake()

func right() -> void:
	index = min(shake_images.keys().size() - 1, index + 1)
	change_shake()

func change_shake(save:bool = true) -> void:
	texture.texture = shake_images[index]
	SaverLoader.game_settings["camera_shake"] = index
	if save:
		SaverLoader.save_gamestate()
