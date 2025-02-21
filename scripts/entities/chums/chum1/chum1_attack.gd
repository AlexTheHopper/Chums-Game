extends State
class_name Chum1_Attack
@onready var state_name := "Attack"

@export var chum: CharacterBody3D
@onready var attack_timer = $AttackTimer


func Physics_Update(delta: float):
	
	#Chase target
	if is_instance_valid(chum.target) and chum.is_on_floor():
		if Functions.distance_between(chum, chum.target) < chum.attack["distance"]:
			attempt_attack()
			chum.velocity = Vector3(0, 0, 0)
		elif chum.anim_player.get_current_animation() != "Attack":
			chum.velocity = lerp(chum.velocity, chum.move_speed * Functions.vector_to_normalized(chum, chum.target), 0.05)
			chum.anim_player.play("Walk")
		
		chum.look_at(chum.target.global_position)
		#chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	chum.move_and_slide()
	
func attempt_attack():
		if attack_timer.time_left > 0:
			return
		chum.do_attack("attack")
		attack_timer.start()
		
func Enter():
	attack_timer.wait_time = chum.attack["speed"]
	chum.anim_player.play("Walk")
