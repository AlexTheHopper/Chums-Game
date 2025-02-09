extends State
class_name Chum1_Knock
@onready var state_name := "Knock"

@export var chum: CharacterBody3D
@onready var player = get_tree().get_first_node_in_group("Player")

func Enter():
	if chum.is_in_group("Chums_Enemy"):	
		chum.make_neutral()

func Physics_Update(delta: float):
	chum.velocity  = lerp(chum.velocity, Vector3(), 0.1)
	
	if Input.is_action_just_pressed("interract"):
		if chum.global_position.distance_to(player.global_position) < 2:
			chum.attempt_carry()
			
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
