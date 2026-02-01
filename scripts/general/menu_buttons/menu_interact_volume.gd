extends MenuInteract

var index := 3
@onready var text_label: Label = $Value
@onready var texture : TextureRect = $TextureRect
@onready var vol_images := {
	0: preload("uid://dvjvk1v3oidts"),
	1: preload("uid://d4iaj7o58q8o0"),
	2: preload("uid://cbicia3lrrdru"),
	3: preload("uid://co5tj48jant4p"),
	4: preload("uid://irdv4i4mcxla"),
}
@export var bus_name: String

func _ready() -> void:
	index = SaverLoader.game_settings["volume_%s" % bus_name]
	if index not in vol_images.keys():
		index = 3
	change_volume(false)

func left() -> void:
	index = max(0, index - 1)
	change_volume()

func right() -> void:
	index = min(vol_images.keys().size() - 1, index + 1)
	change_volume()

func change_volume(save:bool = true) -> void:
	texture.texture = vol_images[index]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(index / 3.0))
	if save:
		SaverLoader.game_settings["volume_%s" % bus_name] = index
		SaverLoader.save_gamestate()
