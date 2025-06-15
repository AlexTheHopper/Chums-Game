extends Node3D

@onready var light = $OmniLight3D
@onready var mesh_scene : Node
var map_size = Global.map_size
var room_location = Global.room_location

func _ready() -> void:
	#Set visuals:
	if Global.current_world_num == 0:
		mesh_scene = load("res://assets/world/streetlamp_%s.tscn" % [Global.room_location[0]]).instantiate()
	elif Global.current_world_num:
		mesh_scene = load("res://assets/world/streetlamp_%s.tscn" % [Global.current_world_num]).instantiate()
	else:
		mesh_scene = load("res://assets/world/streetlamp_1.tscn").instantiate()
	add_child(mesh_scene)
	
	var from_lobby = Global.world_map[Global.room_location]["value"]
	light.omni_attenuation = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(0.2, 0.7))
