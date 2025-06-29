extends State
class_name Chum11_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
var has_touched_floor := false

func Enter():
	chum.anim_player.play("Idle")

func Physics_Update(delta: float):
	if chum.is_on_floor():
		if not has_touched_floor:
			has_touched_floor = true
			chum.velocity = Vector3(0, 0, 0)
	else:
		has_touched_floor = false
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func Exit():
	pass
