extends CharacterBody3D
@export var animation_player: AnimationPlayer
@onready var mesh_scene : Node
@onready var mesh_node := $MeshNode

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[0]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	
	mesh_scene = load("res://assets/world/door_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)

func lower():
	animation_player.play("lower")
	
func raise():
	animation_player.play("raise")
