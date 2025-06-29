extends State
class_name Chum_SleepTemp
@onready var state_name := "SleepTemp"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")
var waking := false

func Enter() -> void:
	chum.anim_player.play("Knock")
	chum.velocity = Vector3(0.0, 0.0 ,0.0)
	chum.create_sleep_particles()
	waking = false
	chum.anim_player.animation_finished.connect(_on_wake_finished)

func Physics_Update(delta: float) -> void:
	if not chum.is_on_floor():
		chum.velocity.y += chum.get_gravity_dir() * delta
	chum.move_and_slide()
	
	chum.temp_sleep_time -= delta
	
	if chum.temp_sleep_time <= 0.0 and not waking:
		waking = true
		chum.anim_player.play("Wake")
		for child in chum.sleep_zone.get_children():
			child.stop_emitting()

func _on_wake_finished(anim_name) -> void:
	if anim_name != "Wake":
		return

	if Global.in_battle:
		Transitioned.emit(self, "Active")
	else:
		Transitioned.emit(self, "Idle")

func Exit() -> void:
	chum.remove_sleep_particles()
	chum.anim_player.animation_finished.disconnect(_on_wake_finished)
