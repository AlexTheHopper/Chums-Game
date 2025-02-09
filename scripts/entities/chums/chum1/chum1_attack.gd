extends State
class_name Chum1_Attack
@onready var state_name := "Attack"

@export var chum: CharacterBody3D


func Physics_Update(delta: float):
	
	#Chase target
	if is_instance_valid(chum.target) and chum.is_on_floor():
		chum.velocity = lerp(chum.velocity, chum.move_speed * Functions.vector_to_normalized(chum, chum.target), 0.05)
		chum.look_at(chum.target.global_position)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	chum.move_and_slide()
		
func Enter():
	chum.hitbox.active = true
	
func Exit():
	chum.hitbox.active = false
