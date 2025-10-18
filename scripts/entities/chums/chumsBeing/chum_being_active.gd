extends State
class_name Chum17_Active
@onready var state_name := "Active"
@onready var chum: CharacterBody3D
var has_touched_floor := false
var rot_tween: PropertyTweener
var pos_tween: PropertyTweener

func Enter():
	chum.anim_player.speed_scale = randf_range(0.8, 1.2)
	chum.anim_player.play("Idle")
	has_touched_floor = false

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.velocity = Vector3(0, 0, 0)
		chum.is_launched = false
		if chum.velocity.length() > 1:
			chum.rotation.y = lerp_angle(chum.rotation.y, Vector2(chum.velocity.x, -chum.velocity.z).angle() + PI/2, 0.5)
		if not has_touched_floor:
			has_touched_floor = true
			chum.set_new_target()
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func Exit():
	chum.is_launched = false
	chum.anim_player.speed_scale = 1.0
