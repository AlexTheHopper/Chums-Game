extends Node3D
class_name Streetlamp

@onready var light = $OmniLight3D
@onready var mesh_scene : Node
var map_size = Global.map_size
var room_location = Global.room_location

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[1]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	if not mesh_num:
		mesh_num = 1
		
	mesh_scene = load("res://assets/world/streetlamp_%s.tscn" % [mesh_num]).instantiate()
	add_child(mesh_scene)
	
	var from_lobby = Global.world_map[Global.room_location]["value"]
	light.omni_attenuation = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(0.2, 0.7))
