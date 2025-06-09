extends Node3D

var wobble_angle := Vector3.ZERO
var wobble_velocity := Vector3.ZERO
var damping := 0.5
var stiffness := 10.0

	
func _physics_process(delta: float) -> void:
	var restoring_force = -wobble_angle * stiffness
	wobble_velocity += restoring_force * delta
	wobble_velocity *= exp(-damping * delta)
	wobble_angle += wobble_velocity * delta
	
	#To account for initial scene rotation:
	#wobble_angle = wobble_angle.rotated(Vector3(0, 1, 0), rotation_degrees.y)

	rotation_degrees.x = wobble_angle.x
	rotation_degrees.z = wobble_angle.z

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		var dir = Functions.vector_to_normalized(area, self)
		wobble_velocity += 3 * Vector3(dir.z * area.damage, 0, -dir.x * area.damage).rotated(Vector3.UP, -rotation.y)
