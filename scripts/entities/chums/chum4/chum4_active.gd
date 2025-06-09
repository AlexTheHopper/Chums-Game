extends State
class_name Chum4_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var attack_timer := $AttackTimer
@onready var nav_timer := $NavTimer
var nav_vel := Vector3(0, 0, 0)
var attacking := false
var has_touched_floor := false

func Enter():
	attack_timer.wait_time = chum.attack["speed"]
	attack_timer.one_shot = true
	attack_timer.autostart = true
	
	nav_timer.wait_time = randf_range(0.2, 0.4)
	nav_timer.timeout.connect(_on_nav_timer_timeout)
	_on_nav_timer_timeout() #Avoids delay before moving
	chum.nav_agent.target_reached.connect(_on_navigation_agent_3d_target_reached)
	chum.nav_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)
	
	chum.anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	chum.anim_player.play("Walk")
	nav_timer.start()
	attacking = false
	has_touched_floor = false

func Physics_Update(delta: float):
	#Chase target
	if not attacking and Functions.distance_squared(chum, chum.target) > pow(chum.default_attack["distance"], 2) and chum.is_on_floor():
		chum.anim_player.play("Walk")
		chum.velocity = nav_vel
		
	if chum.is_on_floor():
		chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		if not has_touched_floor:
			has_touched_floor = true
			chum.set_new_target()
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
		if chum.target != chum.next_target:
			if chum.next_target is Player:
				chum.set_target_to(chum.next_target)
			elif chum.next_target.state_machine.current_state.state_name == "Active":
				chum.set_target_to(chum.next_target)

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
	
	nav_timer.timeout.disconnect(_on_nav_timer_timeout)
	chum.nav_agent.target_reached.disconnect(_on_navigation_agent_3d_target_reached)
	chum.nav_agent.velocity_computed.disconnect(_on_navigation_agent_3d_velocity_computed)
	
	chum.anim_player.animation_finished.disconnect(_on_animation_player_animation_finished)
