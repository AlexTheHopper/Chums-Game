extends State
class_name Chum_Sleep
@onready var state_name := "Sleep"

@onready var chum: CharacterBody3D
@onready var sleep_particles := preload("res://particles/sleep_particles.tscn")
var has_sleep_particles := false

func Enter() -> void:
	chum.call_deferred("enable_interaction")
	chum.anim_player.play("Sleep")
	chum.anim_player.seek(0.1)

	#We dont want the player to be able to push around the chums while theyre sleeping
	chum.set_collision_mask_value(2, false)

func Physics_Update(delta: float) -> void:
	chum.velocity = lerp(chum.velocity, Vector3.ZERO, 0.05)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
	
	if not has_sleep_particles:
		chum.create_sleep_particles()
		has_sleep_particles = true

func Exit() -> void:
	chum.remove_sleep_particles()
	chum.set_new_target()
	
	#If no enemies, set to idle
	if not chum.target:
		Transitioned.emit(self, "Idle")
		
	chum.call_deferred("disable_interaction")
	chum.set_collision_mask_value(2, true)
	
	
