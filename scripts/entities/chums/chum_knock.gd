extends State
class_name Chum_Knock
@onready var state_name := "Knock"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")

func Enter() -> void:
	if chum.current_group == "Chums_Friend":
		PlayerStats.call_deferred("friend_chums_changed", -1, chum)
	chum.make_neutral()
	
	#Allow player,chums to walk through
	chum.set_collision_layer_value(4, false)
	
	chum.set_collision_mask_value(2, false)
	chum.set_collision_mask_value(4, false)
	
	chum.call_deferred("enable_interaction")
	chum.anim_player.play("Knock")
	
	#For chums spawned in knock with 0 health:
	if chum.initial_state_override == "Knock" and chum.start_health == 0:
		chum.anim_player.seek(chum.anim_player.get_animation("Knock").length, true)
		chum.generalchumbehaviour.health_bar.override_ratio(0.0)
		
	#For spawned chums:
	if chum.is_temporary:
		await get_tree().create_timer(0.5).timeout
		chum.get_node("Hurtbox/AnimationPlayer").play("Shrink")

func Physics_Update(delta: float) -> void:
	chum.velocity  = lerp(chum.velocity, Vector3(), 0.1)
	
	if Input.is_action_just_pressed("interact") and len(ChumsManager.close_chums) > 0:
		if ChumsManager.close_chums[0] == chum:
			chum.attempt_carry()
			
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
	
func Exit() -> void:
	#Reallow collisions with player, chums
	chum.set_collision_layer_value(4, true)
	
	chum.set_collision_mask_value(2, true)
	chum.set_collision_mask_value(4, true)
	
	chum.call_deferred("disable_interaction")
