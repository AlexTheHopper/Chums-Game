extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player or body is Chum:
		body.global_position = Global.current_room_node.player_spawn.global_position + Vector3(randf_range(-2, 2), 0.0, randf_range(-2, 2))
