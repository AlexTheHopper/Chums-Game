extends CharacterBody3D

const SPIN_SPEED = 0.1

var x_off = randf() / 100
var z_off = randf() / 100

func _physics_process(delta: float) -> void:
	rotation.y += SPIN_SPEED
	
	position.x += x_off
	position.y += 0.02
	position.z += z_off

	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()
