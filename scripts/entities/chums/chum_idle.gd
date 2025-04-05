extends State
class_name Chum1_Idle
@onready var state_name := "Idle"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var idle_direction: Vector3
@onready var idle_time := 0.0
var wander_offset := randf_range(0, 2 * PI)

func Enter():
	idle_time = 0.0
	chum.call_deferred("enable_interaction")
	
	chum.anim_player.play("Idle")
	
func Update(_delta: float):	
	#Follow player if far enough away, and room beaten:
	if Global.world_map[Global.room_location]["activated"] and chum.can_walk:
		if Functions.distance_squared(chum, player) > pow(chum.follow_distance, 2):
			Transitioned.emit(self, "Follow")

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.velocity = Vector3(0, 0, 0)
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
		
	if Input.is_action_just_pressed("interract") and chum.is_in_group("Chums_Friend") and len(ChumsManager.close_chums) > 0:
		
		if ChumsManager.close_chums[0] == chum and idle_time > 1.0:
			chum.attempt_carry()
	idle_time += delta
	
	chum.move_and_slide()
	
func Exit():
	chum.call_deferred("disable_interaction")
