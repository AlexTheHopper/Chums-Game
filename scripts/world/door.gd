extends CharacterBody3D
@export var animation_player: AnimationPlayer
@onready var mesh_scene : Node
@onready var mesh_node := $MeshNode

func _ready() -> void:
	#Set visuals:
	if Global.current_world_num == 0:
		mesh_scene = load("res://assets/world/door_%s.tscn" % [Global.room_location[0]]).instantiate()
	elif Global.current_world_num:
		mesh_scene = load("res://assets/world/door_%s.tscn" % [Global.current_world_num]).instantiate()
	else:
		mesh_scene = load("res://assets/world/door_1.tscn").instantiate()
	mesh_node.add_child(mesh_scene)

func lower():
	animation_player.play("lower")
	
func raise():
	animation_player.play("raise")
