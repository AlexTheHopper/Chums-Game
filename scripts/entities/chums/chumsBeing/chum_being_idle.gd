extends State
class_name Chum17_Idle
@onready var state_name := "Idle"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var idle_direction: Vector3
@onready var idle_time := 0.0

func Enter():
	idle_time = 0.0
	#set_target_location()
	chum.call_deferred("enable_interaction")
	chum.anim_player.speed_scale = randf_range(0.8, 1.2)
	chum.anim_player.play("Idle")

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.velocity = Vector3(0, 0, 0)
		if chum.velocity.length() > 1:
			chum.rotation.y = lerp_angle(chum.rotation.y, Vector2(chum.velocity.x, -chum.velocity.z).angle() + PI/2, 0.5)
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
		
	if Input.is_action_just_pressed("interact") and chum.is_in_group("Chums_Friend") and len(ChumsManager.close_chums) > 0:
		if ChumsManager.close_chums[0] == chum and idle_time > 1.0:
			chum.attempt_carry()
	idle_time += delta

	chum.move_and_slide()

func Exit():
	chum.call_deferred("disable_interaction")
	chum.anim_player.speed_scale = 1.0
