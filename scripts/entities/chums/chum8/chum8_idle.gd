extends State
class_name Chum8_Idle
@onready var state_name := "Idle"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var idle_direction: Vector3
@onready var idle_time := 0.0
@onready var nav_timer_idle := $NavTimer
var nav_vel := Vector3(0, 0, 0)
var running := true
var target_location : Vector3

func Enter():
	idle_time = 0.0
	set_target_location()
	chum.call_deferred("enable_interaction")
	
	chum.anim_player.play("Idle")
	
	#Navigation
	nav_timer_idle.wait_time = randf_range(0.2, 0.4)
	chum.nav_agent.target_reached.connect(_on_navigation_agent_3d_target_reached_idle)
	chum.nav_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed_idle)
	
	if not is_in_target_room():
		$RunDelay.wait_time = 1.0
		$RunDelay.start()
	

func Physics_Update(delta: float):
	if running:
		chum.velocity = nav_vel
	if chum.is_on_floor():
		if not running:
			chum.velocity = Vector3(0, 0, 0)
		if chum.velocity.length() > 1:
			chum.rotation.y = lerp_angle(chum.rotation.y, Vector2(chum.velocity.x, -chum.velocity.z).angle() + PI/2, 0.5)
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
		
	if Input.is_action_just_pressed("interract") and chum.is_in_group("Chums_Friend") and len(ChumsManager.close_chums) > 0:
		if ChumsManager.close_chums[0] == chum and idle_time > 1.0:
			chum.attempt_carry()
	idle_time += delta

	chum.move_and_slide()

func _on_smack_zone_area_entered(area: Area3D) -> void:
	if area.owner is Player and chum.state_machine.current_state.state_name == "Idle":
		chum.target_room_types.append(chum.target_room_types.pop_front())
		show_target_type()
		if not is_in_target_room():
			$RunDelay.wait_time = 1.0
			$RunDelay.start()

func show_target_type():
	print(chum.target_room_types[0])

func _on_run_delay_timeout() -> void:
	if not is_in_target_room():
		chum.anim_player.play("Walk")
		set_target_location()
		_on_nav_timer_idle_timeout() #Avoids delay before moving
		nav_timer_idle.start()
		running = true
	
func set_target_location() -> void:
	var l = (Global.room_size - 20) / 2
	var dir = Global.world_map_guide[chum.target_room_types[0]][Global.room_location]
	target_location = l * Vector3(dir.x, 0, dir.y) + Vector3(1, 0, 1)

func _on_navigation_agent_3d_target_reached_idle() -> void:
	running = false
	chum.velocity = Vector3(0, 0, 0)
	chum.anim_player.play("Idle")
	nav_timer_idle.stop()
	$RunDelay.stop()

func _on_navigation_agent_3d_velocity_computed_idle(safe_velocity: Vector3) -> void:
	nav_vel = safe_velocity
	
func _on_nav_timer_idle_timeout() -> void:
	chum.nav_agent.target_position = target_location
	var next_location = chum.nav_agent.get_next_path_position()
	var new_vel = (next_location - chum.global_position).normalized() * chum.move_speed
	chum.nav_agent.set_velocity(new_vel)
	
func is_in_target_room():
	if Global.current_room_node.TYPE == chum.target_room_types[0]:
		return true
	return false


func Exit():
	chum.call_deferred("disable_interaction")
	
	nav_timer_idle.stop()
	
	chum.nav_agent.target_reached.disconnect(_on_navigation_agent_3d_target_reached_idle)
	chum.nav_agent.velocity_computed.disconnect(_on_navigation_agent_3d_velocity_computed_idle)
