extends State
class_name Chum9_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
var has_touched_floor := false

func Enter():
	chum.anim_player.speed_scale = 1.0 + (chum.quality["attack_speed"] / 10.0)
	chum.anim_player.play("Attack")
	has_touched_floor = false

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.is_launched = false
		if not has_touched_floor:
			has_touched_floor = true
			chum.velocity = Vector3(0, 0, 0)
	else:
		has_touched_floor = false
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func Exit():
	chum.anim_player.speed_scale = 1.0
	chum.is_launched = false
	chum.hitbox.set_disabled(true)
