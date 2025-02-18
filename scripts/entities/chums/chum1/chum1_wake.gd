extends State
class_name Chum1_Wake
@onready var state_name := "Wake"

@export var chum: CharacterBody3D

func Enter():
	chum.anim_player.play("Wake")

func Physics_Update(delta: float):
	if chum.target:
		chum.look_at(chum.target.global_position)
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func _on_wake_timer_timeout() -> void:
	Transitioned.emit(self, "Attack")
