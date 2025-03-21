extends Node3D

@onready var light = $OmniLight3D
var map_size = Global.map_size
var room_location = Global.room_location

func _ready() -> void:
	var from_lobby = Global.world_map[Global.room_location]["value"]
	light.omni_attenuation = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(0.2, 1.0))
