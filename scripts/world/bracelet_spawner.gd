extends Area3D


func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		var dir = Functions.vector_to_normalized(area, self)
		for i in range(3):
			dir *= randf_range(0.9, 1.1)
			Global.current_room_node.spawn_currency("bracelet", global_position + Vector3(0.0, 1.0, 0.0), 10.0 * dir)
