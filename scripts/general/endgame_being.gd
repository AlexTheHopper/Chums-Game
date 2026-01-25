extends CharacterBody3D

var speed := 1.0
var height := 3.5
var radius := 3.0
var angle := 0.0
var goal_base : Vector3
var goal : Vector3
var world_num_to_prisoner := {1: 17, 2: 18, 3: 19, 4: 20}

func _ready() -> void:
	goal_base = global_position
	if Global.current_world_num in world_num_to_prisoner.keys():
		add_child(load("res://particles/chum%s_particles.tscn" % world_num_to_prisoner[Global.current_world_num]).instantiate())
	else:
		add_child(load("res://particles/chum17_particles.tscn").instantiate())

func _physics_process(delta: float) -> void:
	#Flies in a general circle, then after x time, flies up and queue free
	angle += delta * speed
	goal.x = goal_base.x + (radius * sin(angle))
	goal.y = goal_base.y + height
	goal.z = goal_base.z + (radius * cos(angle))
	global_position = global_position.lerp(goal, delta)

func change_goal(new_goal: Vector3) -> void:
	goal_base = new_goal
