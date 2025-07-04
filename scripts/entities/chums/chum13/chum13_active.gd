extends State
class_name Chum13_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var attack_timer := $AttackTimer

var attacking := false
var has_touched_floor := false

func Enter():
	attack_timer.wait_time = chum.attack_speed
	attack_timer.one_shot = true
	attack_timer.autostart = true
	
	chum.anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	chum.anim_player.play("Jump")
	attacking = false
	has_touched_floor = false

func Physics_Update(delta: float):
	#Jump to target
	if not attacking and chum.is_on_floor() and Functions.distance_squared(chum, chum.target) > chum.attack_distance ** 2:
		chum.anim_player.play("Jump")
	elif not attacking and chum.is_on_floor():
		attempt_attack()
		
	if chum.is_on_floor():
		chum.is_launched = false
		chum.velocity = Vector3(0.0, 0.0 ,0.0)
		chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		if not has_touched_floor:
			has_touched_floor = true
			chum.set_new_target()
	else:
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func attempt_attack():
	if attack_timer.time_left > 0 or attacking:
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

func Exit():
	chum.is_launched = false
	chum.anim_player.animation_finished.disconnect(_on_animation_player_animation_finished)
