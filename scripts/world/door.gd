extends CharacterBody3D
@export var animation_player: AnimationPlayer
@onready var mesh_scene : Node
@onready var mesh_node := $MeshNode

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[1]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	if not mesh_num:
		mesh_num = 1
	
	mesh_scene = load("res://assets/world/door_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)
	
	#Remove if no room to go to
	var dir := Vector2i(0, 0)
	if abs(global_position.x) > abs(global_position.z):
		if global_position.x > 0.0:
			dir = Vector2i(1, 0)
		else:
			dir = Vector2i(-1, 0)
	else:
		if global_position.z > 0.0:
			dir = Vector2i(0, 1)
		else:
			dir = Vector2i(0, -1)
	
	if not Global.has_door(Global.room_location, dir):
		queue_free()

func lower():
	animation_player.play("lower")
	
func raise():
	animation_player.play("raise")
