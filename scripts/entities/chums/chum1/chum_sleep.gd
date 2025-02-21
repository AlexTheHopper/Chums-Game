extends State
class_name Chum1_Sleep
@onready var state_name := "Sleep"

@onready var chum: CharacterBody3D
@export var zs: Node3D
@onready var z_indicator = load("res://scenes/entities/sleeping_indicator_z.tscn")

func Enter():
	chum.interraction_area_shape.set_deferred("disabled", false)
	chum.anim_player.play("Sleep")

func Physics_Update(delta: float):
	chum.velocity = lerp(chum.velocity, Vector3.ZERO, 0.05)
	if randf() < 0.05:
		spawn_z()
		
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()

func spawn_z():
	var z_instance = z_indicator.instantiate()
	zs.add_child(z_instance)

func Exit():
	chum.set_new_target()
	
	#If no enemies, set to idle
	if not chum.target:
		Transitioned.emit(self, "Idle")
		
	chum.interraction_area_shape.set_deferred("disabled", true)
