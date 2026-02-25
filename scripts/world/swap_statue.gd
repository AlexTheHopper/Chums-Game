extends Node3D

@onready var icon_1: Sprite3D = $Icon1
@onready var icon_2: Sprite3D = $Icon2
var chosen_quality: String

func _ready() -> void:
	chosen_quality = ["attack_speed", "attack_damage", "move_speed", "health"][Global.world_map[Global.room_location]["room_specific_id"]]
	icon_1.texture = load("res://assets/world/quality_icons/staticon_%s_world.png" % chosen_quality)
	icon_2.texture = load("res://assets/world/quality_icons/staticon_%s_world.png" % chosen_quality)
