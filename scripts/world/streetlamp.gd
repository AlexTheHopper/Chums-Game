extends Node3D

@onready var light = $OmniLight3D
var map_size = Global.MAP_SIZE
var room_location = Global.room_location

func _ready() -> void:
	var per_to_edge = max(abs(room_location[0]), abs(room_location[1])) / map_size
	light.omni_attenuation = Functions.map_range(per_to_edge, Vector2(0, 1), Vector2(0, 1.0))
