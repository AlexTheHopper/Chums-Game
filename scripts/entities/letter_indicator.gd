extends StaticBody3D

const SPIN_SPEED = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += deg_to_rad(SPIN_SPEED)
	
func appear():
	$AnimationPlayer.play("fade_in")
	
func disappear():
	$AnimationPlayer.play("fade_out")
