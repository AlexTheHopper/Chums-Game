extends State
class_name Chum1_Wake
@onready var state_name := "Wake"

@onready var chum: CharacterBody3D

func Enter():
	chum.anim_player.play("Wake")

func Physics_Update(delta: float):
	if chum.target:
		chum.rotation.y = lerp_angle(chum.rotation.y, Functions.angle_to_xz(chum, chum.target), 0.5)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func _on_wake_timer_timeout() -> void:
	Transitioned.emit(self, "Active")
