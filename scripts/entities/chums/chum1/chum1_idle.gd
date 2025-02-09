extends State
class_name Chum1_Idle
@onready var state_name := "Idle"

@export var chum: CharacterBody3D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var idle_direction: Vector3
@onready var idle_time := 0.0
	
func Update(delta: float):
	if Input.is_action_just_pressed("interract") and chum.is_in_group("Chums_Friend"):
		if chum.global_position.distance_to(player.global_position) < 2:
			chum.attempt_carry()
	idle_time += delta

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.velocity = 1 * Vector3(cos(idle_time), 0, sin(idle_time))
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
