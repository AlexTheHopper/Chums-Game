extends State
class_name Chum1_Sleep
@onready var state_name := "Sleep"

@onready var chum: CharacterBody3D
@onready var sleep_particles = preload("res://particles/sleep_particles.tscn")

func Enter():
	chum.call_deferred("enable_interaction")
	chum.anim_player.play("Sleep")
	call_deferred("create_sleep_particles")
	
	#We dont want the player to be able to push around the chums while theyre sleeping
	chum.set_collision_mask_value(2, false)

func create_sleep_particles():
	chum.create_sleep_particles()


func Physics_Update(delta: float):
	chum.velocity = lerp(chum.velocity, Vector3.ZERO, 0.05)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func Exit():
	chum.set_new_target()
	
	#If no enemies, set to idle
	if not chum.target:
		Transitioned.emit(self, "Idle")
		
	chum.call_deferred("disable_interaction")
	chum.set_collision_mask_value(2, true)
	
	chum.remove_sleep_particles()
