extends State
class_name Chum1_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var attack_timer = $AttackTimer
@onready var nav_timer = $NavTimer
var nav_vel := Vector3(0, 0, 0)
var attacking := false

func Enter():
	attack_timer.wait_time = chum.attack["speed"]
	chum.anim_player.play("Walk")
	nav_timer.start()

func Physics_Update(delta: float):
	#Chase target
	if not attacking and Functions.distance_squared(chum, chum.target) > pow(chum.default_attack["distance"], 2):
		chum.anim_player.play("Walk")
		#chum.look_at(chum.target.global_position)
	chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		
	
	if chum.is_on_floor():
		chum.velocity = nav_vel
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
	
func _on_navigation_agent_3d_target_reached() -> void:
	attempt_attack()
	
func attempt_attack():
	if attack_timer.time_left > 0:
		return
	attacking = true
	chum.velocity = Vector3(0, 0, 0)
	chum.do_attack("attack")
	attack_timer.start()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		attacking = false
		

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	nav_vel = safe_velocity


func _on_nav_timer_timeout() -> void:
	if chum.target:
		chum.nav_agent.target_position = chum.target.global_position
		var next_location = chum.nav_agent.get_next_path_position()
		var new_vel = (next_location - chum.global_position).normalized() * chum.move_speed
		chum.nav_agent.set_velocity(new_vel)
		
func Exit():
	nav_timer.stop()
