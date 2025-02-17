extends State
class_name Chum1_Carry
@onready var state_name := "Carry"

@export var chum: CharacterBody3D
@onready var player = get_tree().get_first_node_in_group("Player")

var throw_vel_i: Vector3
var throw_hor := 10.0
var throw_vert := 7.5

func Physics_Update(delta: float):
	chum.global_position  = lerp(chum.global_position, player.global_position + Vector3(0, 2, 0), 0.8)
	throw_vel_i = (Vector3(0, throw_hor, 0) + Vector3(0, 0, -throw_vert).rotated(Vector3.UP, player.get_node("Armature").rotation.y))
	if Input.is_action_just_pressed("interract"):
		chum.velocity = throw_vel_i
		player.is_carrying = false
		if len(get_tree().get_nodes_in_group("Chums_Enemy")) > 0:
			Transitioned.emit(self, "Attack")
		else:
			Transitioned.emit(self, "Idle")
			
	chum.move_and_slide()

func Enter():
	if not chum.is_in_group("Chums_Friend"):
		chum.make_friendly()
	
func Exit():
	chum.set_new_target()
