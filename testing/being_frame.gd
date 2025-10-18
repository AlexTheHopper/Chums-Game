extends Node3D

func _ready() -> void:
	change_rotation()
	$AnimationPlayer.play("Attack")
	
func change_rotation() -> void:
	var new_rot = Vector3(randf()*2*PI,randf()*2*PI,randf()*2*PI)
	var new_pos = Vector3(randf_range(-0.6,0.6),randf_range(-0.6,0.6),randf_range(-0.6,0.6))
	var time = randf_range(1.5,2.5)
	$AnimationPlayer.speed_scale = randf_range(0.75,1.0)
	var rot_tween = get_tree().create_tween().tween_property($Base, "rotation", new_rot, time) #tween out current
	var _pos_tween = get_tree().create_tween().tween_property($Base/BeingParticles, "position", new_pos, time) #tween out current
	rot_tween.finished.connect(change_rotation)
