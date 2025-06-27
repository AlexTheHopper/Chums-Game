extends State
class_name Chum1_Wake
@onready var state_name := "Wake"

@onready var chum: CharacterBody3D

func Enter():
	chum.anim_player.play("Wake")
	chum.anim_player.animation_finished.connect(woken)

func Physics_Update(delta: float):
	if chum.target and chum.has_move_speed:
		chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
	
func woken(anim_name) -> void:
	if anim_name == "Wake":
		Transitioned.emit(self, "Active")
