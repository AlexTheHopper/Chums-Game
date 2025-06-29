extends State
class_name Chum_Follow
@onready var state_name := "Follow"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")

func Enter() -> void:
	if not chum.has_move_speed:
		chum.anim_player.play("Walk")
		return
	chum.anim_player.play("Walk")
	chum.set_target_to(player)

func Physics_Update(delta: float) -> void:
	chum.velocity = lerp(chum.velocity, chum.move_speed * Functions.vector_to_normalized(chum, chum.target), 0.05)
	#chum.anim_player.play("Walk")

	chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	chum.move_and_slide()
	
	#Go to idle if close enough:
	if Functions.distance_squared(chum, chum.target) < pow(chum.follow_distance - 1, 2):
		Transitioned.emit(self, "Idle")

func Exit() -> void:
	pass
